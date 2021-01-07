const express = require("express");
const http = require("http");
const path = require("path");

const app = express();
const server = http.createServer(app);

// # GET ROUTE
app.get("*", (req, res) => {
  res.sendFile(path.resolve(__dirname, "public", "index.html"));
});

// # LISTEN TO SERVER
server.listen(8080, () => {
  console.log("SERVER IS STARTING ON PORT 8080");
});

module.exports = app;
