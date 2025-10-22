const express = require('express')
const app = express()
const port = 8001

app.get('/send-key/:key', (req, res) => {
    var key = req.params.key;
    key = key.toUpperCase();
    if(!key.startsWith("KEY_"))
      key = "KEY_" + key;
    remote.isAlive((err) => {
        if (err) {
            console.error('TV is offline when sending key ' + key);
        } else {
            remote.send(key, (err) => {
                if (err) {
                    console.error("Error sending key " +  key);
                    console.error(err);
                    res.send("Error sending key " +  key);
                } else {
                    console.log("Finished sending key " +  key);
                    res.send("Finished sending key " +  key);
                }
            });
        }
    });
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})


const SamsungRemote = require('samsung-remote');
const remote = new SamsungRemote({
    ip: '192.168.2.18'
});
