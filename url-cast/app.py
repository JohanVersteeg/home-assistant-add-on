from flask import Flask, request, jsonify
import subprocess
import re
import logging
import sys

# --- Logging Configuration ---
# This sets the log level to INFO and directs it to stdout
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

def get_catt_devices():
    """Parses 'catt scan' output into a list of dictionaries."""
    logger.info("Starting 'catt scan'...")
    try:
        # Run catt scan (this usually takes about 10 seconds)
        result = subprocess.run(['catt', 'scan'], capture_output=True, text=True, timeout=20)
        
        if result.returncode != 0:
            logger.error(f"Catt scan failed with stderr: {result.stderr}")
            return {"error": result.stderr}

        lines = result.stdout.splitlines()
        devices = []
        # Pattern to match: "Device Name" - 192.168.x.x
        pattern = re.compile(r'^(.*)\s-\s(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})')
        
        for line in lines:
            match = pattern.match(line.strip())
            if match:
                device_info = {
                    "name": match.group(1).strip(),
                    "ip": match.group(2).strip()
                }
                devices.append(device_info)
        
        logger.info(f"Scan complete. Found {len(devices)} devices.")
        return devices

    except subprocess.TimeoutExpired:
        logger.warning("Catt scan timed out after 20 seconds.")
        return {"error": "Scan timed out"}
    except Exception as e:
        logger.exception("An unexpected error occurred during scan")
        return {"error": str(e)}

@app.route('/scan', methods=['GET'])
def scan_devices():
    logger.info("Received request for /scan")
    devices = get_catt_devices()
    return jsonify({"devices": devices})

@app.route('/cast', methods=['GET'])
def cast_url():
    device = request.args.get('cast_device')
    url = request.args.get('url')

    if not device or not url:
        logger.warning(f"Cast request missing parameters: device={device}, url={url}")
        return jsonify({"error": "Missing parameters. Need 'cast_device' and 'url'"}), 400

    logger.info(f"Attempting to cast URL '{url}' to device '{device}'")
    
    try:
        # Run: catt -d "Device Name/IP" cast "URL"
        result = subprocess.run(['catt', '-d', device, 'cast', url], capture_output=True, text=True)
        
        if result.returncode == 0:
            logger.info(f"Successfully started casting to {device}")
            return jsonify({"status": "success", "device": device, "url": url}), 200
        else:
            logger.error(f"Catt cast failed: {result.stderr}")
            return jsonify({"status": "error", "message": result.stderr}), 500
    except Exception as e:
        logger.exception(f"Exception during cast to {device}")
        return jsonify({"status": "exception", "message": str(e)}), 500

if __name__ == '__main__':
    logger.info("Starting Flask server on port 5000...")
    app.run(host='0.0.0.0', port=5000)