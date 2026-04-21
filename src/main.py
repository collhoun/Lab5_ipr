try:
    from src.calculator import calculate
except ModuleNotFoundError:
    import sys

    sys.path.append(".")
    from src.calculator import calculate

from flask import Flask, request, render_template_string

app = Flask(__name__)


@app.route("/", methods=["GET", "POST"])
def index():
    import os

    greeting = os.getenv("GREETING_MSG", "Welcome to Python Calculator!")
    debug = os.getenv("APP_DEBUG", "false").lower() == "true"
    secret_token = os.getenv("SECRET_TOKEN", "")

    app.debug = debug

    if secret_token:
        print(f"Secret token loaded: {secret_token}")

    result = None
    error = None

    if request.method == "POST":
        expression = request.form.get("expression", "").strip()
        if expression:
            try:
                result = calculate(expression)
            except (ValueError, ZeroDivisionError, TypeError) as e:
                error = str(e)

    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Calculator</title>
    </head>
    <body>
        <h1>{greeting}</h1>
        <form method="post">
            <label for="expression">Enter expression:</label>
            <input type="text" id="expression" name="expression" required>
            <button type="submit">Calculate</button>
        </form>
        {"<p>Result: " + str(result) + "</p>" if result is not None else ""}
        {'<p style="color: red;">Error: ' + error + "</p>" if error else ""}
    </body>
    </html>
    """
    return render_template_string(html)


if __name__ == "__main__":
    import os

    port = int(os.getenv("PORT", "8080"))
    app.run(host="0.0.0.0", port=port)
