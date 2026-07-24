const functions = require("firebase-functions");
const fetch = require("node-fetch");

exports.chatWithTutor = functions.https.onCall(async (data, context) => {
  const { message, language, history } = data;

  const systemPrompt = `You are a friendly language tutor teaching ${language}.
  The user will write in ${language} or English.
  1. If there are grammar mistakes, gently correct them.
  2. Reply naturally in ${language}.
  3. Always include an English translation of your reply in brackets.
  Keep responses short (2-4 sentences).`;

  const messages = [
    ...(history || []),
    { role: "user", content: message },
  ];

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": functions.config().anthropic.key,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-sonnet-4-5",
      max_tokens: 300,
      system: systemPrompt,
      messages: messages,
    }),
  });

  const result = await response.json();
  const botReply = result.content[0].text;

  return { reply: botReply };
});