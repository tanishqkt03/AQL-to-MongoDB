from flask import Flask, request, jsonify
from flask_cors import CORS
import subprocess

app = Flask(__name__)
CORS(app)

@app.route("/translate", methods=["POST"])
def translate():
    aql = request.json.get("aql")

    # Save the input query to a file
    with open("input.aql", "w") as f:
        f.write(aql + "\n")  # newline ensures parser ends reading

    try:
        # Run the compiled parser and feed it the input file via stdin
        result = subprocess.run(
            ["./parser/aql_parser"],
            input=aql.encode(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=3  # avoid hanging forever
        )

        output = result.stdout.decode().strip()
        error = result.stderr.decode().strip()

        if result.returncode != 0:
            return jsonify({"error": f"Parser error:\n{error}"}), 500

        return jsonify({"mongo": output})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)
