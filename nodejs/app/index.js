const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Node.js cyan</title>
        <style>
          body {
            background-color: cyan;
            color: white;
            font-family: sans-serif;
            text-align: center;
            padding-top: 100px;
          }
        </style>
      </head>
      <body>
        <h1>Hello from Cyan Version!</h1>
      </body>
    </html>
  `);
});

app.listen(port, () => {
  console.log(`Node.js app running on port ${port}`);
});
