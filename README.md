# Titan StudyMate — Assembly Edition

Titan StudyMate is a small AI study helper for students in Classes 1–12. It asks Google Gemini to explain a student's question in clear, friendly Hinglish, tailored to the selected class and subject.

The application has been rewritten as a **single x86-64 Linux GNU assembly program**. Its HTTP server, form parsing, HTML rendering, prompt construction, JSON escaping/parsing, and response handling are implemented in `src/titan_studymate.S`. The HTML and CSS are embedded as read-only data in that assembly source; there is no Python, JavaScript, or separate frontend runtime. `curl` is used as the HTTPS/TLS transport to the Gemini API.

## Requirements

- 64-bit Linux on x86-64
- GCC and GNU binutils
- `make`
- `curl`
- A Google Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey)

## Build and run

```sh
make
GOOGLE_API_KEY="your_api_key" ./build/titan-studymate
```

Then open <http://localhost:8501>. The server binds to `0.0.0.0` so it can also run in a container or hosted preview.

Configuration is read from environment variables:

| Variable | Default | Purpose |
| --- | --- | --- |
| `GOOGLE_API_KEY` | *(unset)* | Required to request Gemini answers. The web form still loads without it and displays setup guidance if submitted. |
| `PORT` | `8501` | HTTP listen port (1–65535). |
| `GEMINI_MODEL` | `gemini-2.5-flash` | Gemini model name used by the REST request. |

For example:

```sh
GOOGLE_API_KEY="your_api_key" PORT=8501 make run
```

To remove the compiled program:

```sh
make clean
```

## Notes

- Requests are handled sequentially by a small built-in HTTP/1.1 server. The browser form uses ordinary URL-encoded POSTs; no client-side JavaScript is needed.
- The API key is sent to `curl` as an `x-goog-api-key` header through a transient pipe-backed config descriptor—not as a command-line argument or a file on disk.
- Student questions are sent to Google's Gemini API to generate an answer. Avoid entering sensitive personal information.
