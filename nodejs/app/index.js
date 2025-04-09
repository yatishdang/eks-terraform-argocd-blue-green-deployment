const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Node.js Blue</title>
        <style>
          body {
            background-color: blue;
            color: white;
            font-family: sans-serif;
            text-align: center;
            padding-top: 100px;
          }
        </style>
      </head>
      <body>
        <h1>Hello from Blue Version!</h1>
      </body>
    </html>
  `);
});

app.listen(port, () => {
  console.log(`Node.js app running on port ${port}`);
});
