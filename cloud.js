const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const { WebhookClient } = require("dialogflow-fulfillment");
const { GoogleAuth } = require("google-auth-library");

admin.initializeApp();
const firestore = admin.firestore();
const GOOGLE_PLACES_API_KEY = “YOUR_GOOGLE_API”; // Replace if needed

// --- Helper Functions ---

async function formatRestaurantResponse(restaurants, offset) {
  // This function is no longer used to build a text response,
  // but you can still use it for logging or fallback text.
  let responseText = `🍽️ **Here are some great restaurant options:**\n\n`;
  restaurants.forEach((r, index) => {
    let priceEmoji = "💲".repeat(r.price_level);
    responseText += `**${index + 1 + offset}. [${r.name}](${r.link})**\n📍 Address: ${r.address}\n⭐ Rating: ${r.rating}\n💰 Price: ${priceEmoji || "N/A"}\n\n`;
  });
  return responseText;
}

function isOpenAtTime(place, desiredTime) {
  if (!place.opening_hours || !place.opening_hours.periods) return true; // Assume open if no data
  const userTime = parseInt(desiredTime.replace(":", ""), 10);
  const currentDay = new Date().getDay();
  for (const period of place.opening_hours.periods) {
    if (period.open && period.open.day === currentDay && period.open.time) {
      const openTime = parseInt(period.open.time, 10);
      const closeTime = period.close && period.close.time ? parseInt(period.close.time, 10) : 2400;
      if (userTime >= openTime && userTime < closeTime) return true;
    }
  }
  return false;
}

function isOutdoorOnly(place) {
  if (!place.types) return false;
  const outdoorTypes = ["park", "campground", "stadium"];
  return outdoorTypes.some(type => place.types.includes(type));
}

async function getRestaurants(city, cuisine, minRating = 3.5, priceLevel = null, desiredTime = null, weather = null, offset = 0, limit = 20) {
  try {
    const apiUrl = `https://maps.googleapis.com/maps/api/place/textsearch/json?query=${encodeURIComponent(cuisine + " restaurant in " + city)}&key=${GOOGLE_PLACES_API_KEY}`;
    console.log("Google Places API Request URL:", apiUrl);
    const response = await axios.get(apiUrl);
    console.log("Google Places API Response Received");
    console.log("Raw results:", response.data.results);
    
    let filteredRestaurants = response.data.results.filter(place => {
      if (place.rating < minRating) return false;
      if (priceLevel && place.price_level !== priceLevel) return false;
      if (desiredTime && !isOpenAtTime(place, desiredTime)) return false;
      if (weather && weather.toLowerCase() === "rainy" && isOutdoorOnly(place)) return false;
      if (place.opening_hours && place.opening_hours.open_now === false) return false;
      return true;
    });
    filteredRestaurants.sort((a, b) => b.rating - a.rating);
    
    let fallback = false;
    if (filteredRestaurants.length === 0) {
      console.log("Strict filtering yielded no results. Applying fallback filter...");
      filteredRestaurants = response.data.results.filter(place => {
        if (place.rating < (minRating - 0.5)) return false;
        // Skip time check in fallback.
        if (weather && weather.toLowerCase() === "rainy" && isOutdoorOnly(place)) return false;
        return true;
      });
      if (filteredRestaurants.length > 0) fallback = true;
    }
    
    const finalList = filteredRestaurants.slice(offset, offset + limit).map(place => ({
      name: place.name,
      rating: place.rating,
      price_level: place.price_level || "N/A",
      address: place.formatted_address || place.vicinity || "Address not available",
      link: `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(place.name)}`,
      place_id: place.place_id
    }));
    
    return { restaurants: finalList, fallback };
  } catch (error) {
    console.error("Error fetching Google Places data:", error);
    return { restaurants: [], fallback: false };
  }
}

// --- User Preference Storage Helper ---
async function updateUserPreferences(uid, cuisine, location) {
  try {
    const userRef = firestore.collection("users").doc(uid);
    await userRef.set({
      preferences: {
        lastUsedLocation: location,
        locationHistory: admin.firestore.FieldValue.arrayUnion(location),
        cuisineCount: {
          [cuisine]: admin.firestore.FieldValue.increment(1)
        }
      },
      lastSession: { cuisine, location }
    }, { merge: true });
  } catch (error) {
    console.error("Error updating user preferences:", error);
  }
}

// --- Webhook Intent Handlers ---

async function restaurantRecommendation(agent) {
  console.log("Entered restaurantRecommendation function");
  const parameters = agent.request_.body.queryResult.parameters;
  
  let location = parameters.location?.city || null;
  let cuisine = parameters.cuisine?.[0] || null;
  const minRating = parameters.stars || 4.0;
  let pricePreference = parameters.priceMap || null;
  
  let desiredTime = parameters.time || null; // e.g., "20:00"
  let weather = parameters.weather || null;   // e.g., "rainy"
  
  // Optionally extract a UID from the request
  let uid = null;
  if (agent.request_.body.uid) {
    uid = agent.request_.body.uid;
  } else if (agent.request_.body.originalDetectIntentRequest && 
             agent.request_.body.originalDetectIntentRequest.payload && 
             agent.request_.body.originalDetectIntentRequest.payload.user && 
             agent.request_.body.originalDetectIntentRequest.payload.user.uid) {
    uid = agent.request_.body.originalDetectIntentRequest.payload.user.uid;
  }
  
  const sessionId = agent.session;
  
  // Use cached values if missing, or fall back on stored user preferences if UID is available.
  const cachedDoc = await firestore.collection("cached_requests").doc(sessionId).get();
  if (cachedDoc.exists) {
    const cachedData = cachedDoc.data();
    if (!location) location = cachedData.location;
    if (!cuisine) cuisine = cachedData.cuisine;
  }
  if ((!location || !cuisine) && uid) {
    const userRef = firestore.collection("users").doc(uid);
    const userDoc = await userRef.get();
    if (userDoc.exists) {
      const userData = userDoc.data();
      if (!location && userData?.lastSession?.location) location = userData.lastSession.location;
      if (!cuisine && userData?.lastSession?.cuisine) cuisine = userData.lastSession.cuisine;
    }
  }
  
  if (!location || !cuisine) {
    agent.add("Please specify both a cuisine and a city.");
    return;
  }
  
  console.log(`Searching for ${cuisine} restaurants in ${location} with minRating: ${minRating}, desiredTime: ${desiredTime}, weather: ${weather}`);
  
  if (uid) {
    await updateUserPreferences(uid, cuisine, location);
  }
  
  const { restaurants, fallback } = await getRestaurants(location, cuisine, minRating, pricePreference, desiredTime, weather, 0, 20);
  if (!restaurants || restaurants.length === 0) {
    agent.add(`Sorry, I couldn't find any ${cuisine} restaurants in ${location} matching your criteria.`);
    return;
  }
  
  // Cache results for pagination.
  await firestore.collection("cached_requests").doc(sessionId).set({
    restaurants,
    location,
    cuisine,
    offset: 7
  });
  
  let responseText = await formatRestaurantResponse(restaurants.slice(0, 7), 0);
  if (fallback) {
    responseText = "I couldn't find exact matches based on your criteria. Here are some close suggestions:\n\n" + responseText;
  } else {
    responseText += `Would you like to see more results? Just say "Show more"!`;
  }
  console.log("Generated response:", responseText);
  // Instead of a simple text response, return structured data for flash cards.
  res.json({ 
    restaurants: restaurants.slice(0, 7),
    fallback: fallback,
    message: responseText 
  });
}

async function showMoreRestaurants(agent) {
  console.log("Handling 'Show More' request");
  const sessionId = agent.session;
  const cachedDoc = await firestore.collection("cached_requests").doc(sessionId).get();
  if (!cachedDoc.exists) {
    agent.add("I can't find previous search results. Please try searching again.");
    return;
  }
  const cachedData = cachedDoc.data();
  let { restaurants, offset, cuisine, location } = cachedData;
  if (!restaurants || offset >= restaurants.length) {
    await firestore.collection("cached_requests").doc(sessionId).delete();
    agent.add(`No more cached results! Let me find some new ${cuisine} restaurants in ${location} for you.`);
    return restaurantRecommendation(agent);
  }
  let responseText = await formatRestaurantResponse(restaurants.slice(offset, offset + 7), offset);
  await firestore.collection("cached_requests").doc(sessionId).update({ offset: offset + 7 });
  responseText += `Would you like to see more results? Just say "Show more"!`;
  console.log("Sending more results:", responseText);
  agent.add(responseText);
}

async function provideRestaurantDetails(agent) {
  console.log("Handling restaurant details request");
  const parameters = agent.request_.body.queryResult.parameters;
  let requestedName = parameters.restaurant;
  if (!requestedName) {
    agent.add("Please specify the restaurant name for which you'd like more details.");
    return;
  }
  requestedName = requestedName.trim().toLowerCase();
  const sessionId = agent.session;
  const cachedDoc = await firestore.collection("cached_requests").doc(sessionId).get();
  let restaurantEntry = null;
  if (cachedDoc.exists) {
    const cachedData = cachedDoc.data();
    restaurantEntry = cachedData.restaurants.find(r => r.name.trim().toLowerCase().includes(requestedName));
  }
  if (!restaurantEntry) {
    agent.add("I couldn't find that restaurant in your previous search. Please try again with the correct name.");
    return;
  }
  if (!restaurantEntry.place_id) {
    agent.add("I'm sorry, I don't have detailed information about that restaurant.");
    return;
  }
  const details = await getRestaurantDetails(restaurantEntry.place_id);
  if (!details) {
    agent.add("I'm sorry, I couldn't retrieve more details about that restaurant.");
    return;
  }
  let responseText = `**${details.name}**\n\n`;
  responseText += `📍 Address: ${details.address}\n`;
  responseText += `📞 Phone: ${details.phone}\n`;
  responseText += `🌐 Website: ${details.website}\n`;
  responseText += `⭐ Rating: ${details.rating}\n`;
  responseText += `🏷️ Types: ${details.types}\n\n`;
  if (details.reviews && details.reviews.length > 0) {
    responseText += `**Top Reviews:**\n`;
    details.reviews.forEach(review => {
      responseText += `- ${review.author_name}: "${review.text}" (${review.rating}⭐)\n`;
    });
  }
  agent.add(responseText);
}

async function getRestaurantDetails(place_id) {
  const detailsUrl = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${place_id}&key=${GOOGLE_PLACES_API_KEY}`;
  try {
    const response = await axios.get(detailsUrl);
    if (response.data.status !== "OK") {
      console.error("Google Place Details API Error:", response.data);
      return null;
    }
    const result = response.data.result;
    return {
      name: result.name,
      address: result.formatted_address || result.vicinity || "Address not available",
      phone: result.formatted_phone_number || "N/A",
      website: result.website || "N/A",
      rating: result.rating,
      reviews: result.reviews ? result.reviews.slice(0, 3) : [],
      types: result.types ? result.types.join(", ") : "N/A"
    };
  } catch (error) {
    console.error("Error fetching place details:", error);
    return null;
  }
}

// --- Main Webhook Handler ---
exports.dialogflowWebhook = functions.https.onRequest(async (req, res) => {
  try {
    console.log("🔥 Received request:", JSON.stringify(req.body, null, 2));
    
    // If the request is a minimal payload (raw text and session), call detectIntent.
    if (req.body.text && req.body.session) {
      const userText = req.body.text;
      const sessionId = req.body.session;
      
      const auth = new GoogleAuth({
        scopes: ["https://www.googleapis.com/auth/dialogflow"]
      });
      const client = await auth.getClient();
      const accessToken = await client.getAccessToken();
      
      const projectId = “YOUR_PROJECT_ID”; // Your Dialogflow project ID.
      const url = `https://dialogflow.googleapis.com/v2/projects/${projectId}/agent/sessions/${sessionId}:detectIntent`;
      
      const dialogflowPayload = {
        queryInput: {
          text: {
            text: userText,
            languageCode: "en-US"
          }
        }
      };
      
      console.log("Calling Dialogflow detectIntent with payload:", dialogflowPayload);
      const responseDF = await axios.post(url, dialogflowPayload, {
        headers: {
          Authorization: `Bearer ${accessToken.token || accessToken}`,
          "Content-Type": "application/json"
        }
      });
      
      return res.json(responseDF.data);
    }
    // Else, if it's a full Dialogflow webhook request:
    else if (req.body.queryResult) {
      const agent = new WebhookClient({ request: req, response: res });
      const intent = req.body.queryResult.intent.displayName || "";
      console.log(`Detected Intent: ${intent}`);
      
      // Fallback for greetings.
      const rawQuery = req.body.queryResult.queryText?.trim().toLowerCase() || "";
      if (intent === "Default Welcome Intent" || rawQuery === "hi" || rawQuery === "hello") {
        agent.add("Hello! How can I help you with restaurant recommendations today?");
        return;
      }
      
      let intentMap = new Map();
      intentMap.set("venues.eating_out.search", restaurantRecommendation);
      intentMap.set("venues.eating_out.show_more", showMoreRestaurants);
      intentMap.set("venues.eating_out.details", provideRestaurantDetails);
      
      if (!intentMap.has(intent)) {
        console.error(`No handler found for intent: ${intent}`);
        return res.status(500).send(`Error: No handler found for intent: ${intent}`);
      }
      agent.handleRequest(intentMap);
    } else {
      return res.status(400).send("Invalid or unknown request type.");
    }
  } catch (error) {
    console.error("Internal Server Error:", error);
    res.status(500).send("Internal Server Error: " + error.message);
  }
});