from flask import Flask, request, jsonify
import subprocess
import re

app = Flask(__name__)

def get_catt_devices():
    """Parses 'catt scan' output into a list of dictionaries."""
    try:
        # Run catt scan (this usually takes about 10 seconds)
        result = subprocess.run(['catt', 'scan'], capture_output=True, text=True, timeout=20)
        lines = result.stdout.splitlines()
        
        devices = []
        # Pattern to match: "Device Name" - 192.168.x.x
        pattern = re.compile(r'^(.*)\s-\s(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})')
        
        for line in lines:
            match = pattern.match(line.strip())
            if match:
                devices.append({
                    "name": match.group(1).strip(),
                    "ip": match.group(2).strip()
                })
        return devices
    except Exception as e:
        return {"error": str(e)}

@app.route('/scan', methods=['GET'])
def scan_devices():
    devices = get_catt_devices()
    return jsonify({"devices": devices})

@app.route('/cast', methods=['GET'])
def cast_url():
    device = request.args.get('cast_device')
    url = request.args.get('url')

    if not device or not url:
        return jsonify({"error": "Missing parameters. Need 'cast_device' and 'url'"}), 400

    try:
        # Run: catt -d "Device Name/IP" cast "URL"
        result = subprocess.run(['catt', '-d', device, 'cast', url], capture_output=True, text=True)
        
        if result.returncode == 0:
            return jsonify({"status": "success", "device": device, "url": url}), 200
        else:
            return jsonify({"status": "error", "message": result.stderr}), 500
    except Exception as e:
        return jsonify({"status": "exception", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)