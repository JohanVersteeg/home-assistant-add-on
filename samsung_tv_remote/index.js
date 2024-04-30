const express = require('express')
const app = express()
const port = 8001


var delay = 1000;

app.get('/screen-off', (req, res) => {
    turnOff();
  res.send('Screen off');
})

app.get('/screen-on', (req, res) => {
    turnOn();
  res.send('Screen on');
})

app.get('/send-key/:key', (req, res) => {
    remote.isAlive((err) => {
        if (err) {
            console.error('TV is offline');
        } else {
            remote.send(req.params.key, (err) => {
                if (err) {
                    console.error("Error sending key " +  req.params.key);
                    console.error(err);
                } else {
                    console.log("Finished sending key " +  req.params.key);
                    res.send("Finished sending key " +  req.params.key);
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
    ip: '192.168.2.136'
});

function turnOff() {
    remote.isAlive((err) => {
        if (err) {
            console.error('TV is offline');
        } else {

            remote.send('KEY_TOOLS', (err) => {
                if (err) {
                    console.error(err);
                } else {
                    setTimeout(() => {
                        remote.send('KEY_UP', (err) => {
                            if (err) {
                                console.error(err);
                            } else {
                                setTimeout(() => {
                                    remote.send('KEY_ENTER', (err) => {
                                        if (err) {
                                            console.error(err);
                                        }
                                    });
                                }, delay);
                            }
                        });
                    }, delay);
                }
            });
        }
    });
}






function turnOn() {
    remote.isAlive((err) => {
        if (err) {
            console.error('TV is offline');
        } else {
            remote.send('KEY_RETURN', (err) => {
                if (err) {
                    console.error(err);
                } else {
                    setTimeout(() => {
                        remote.send('KEY_RETURN', (err) => {
                            if (err) {
                                console.error(err);
                            } else {
                                setTimeout(() => {
                                    remote.send('KEY_RETURN', (err) => {
                                        if (err) {
                                            console.error(err);
                                        }
                                    });
                                }, delay);
                            }
                        });
                    }, delay);
                }
            });
        }
    });
}