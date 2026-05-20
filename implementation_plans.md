# Implementation Plans & Task Lists

This document serves as a living record of all implementation plans, task lists, and walkthroughs generated during the development of SnakeGuard Lite. It will be updated with each new phase or prompt.

---

## Phase 1: Repository Cleanup and Environment Setup

### Workplan
1. **Delete Old Frontend:** Removed the old Streamlit frontend at `AI-Hackathone/frontend/app.py`.
2. **Create Environment File:** Created a `.env` file containing the dummy Gemini API key.
3. **Ignore Secrets:** Created the `.gitignore` inside the `SnakeGuard_Agent` folder to make sure the newly created `.env` is not tracked by Git.
4. **Folder Structure Inspection:** Ran the `tree` command to view the updated project layout. 

### Implementation Plan with Reasoning
- **Task 1:** Replaced Streamlit with Flutter, which meant the old Python app file was obsolete and needed to be purged to avoid confusion.
- **Task 2:** We needed a place to store secret configuration keys like `GEMINI_API_KEY` securely locally, separated from the codebase.
- **Task 3:** `AI-Hackathone/SnakeGuard_Agent/.gitignore` didn't exist yet, so we created it and populated it with `.env`. This ensures developers won't accidentally check the Gemini API key into version control.
- **Task 4:** To confirm the layout, we requested a file tree of the `AI-Hackathone` directory to visualize the current state of the app including the new Flutter structure.

### List of Files Changed
- **Deleted:** `AI-Hackathone/frontend/app.py`
- **Created:** `AI-Hackathone/.env`
- **Created:** `AI-Hackathone/SnakeGuard_Agent/.gitignore`

---
# Implementation Plan – End‑to‑End Integration of SnakeGuard

## 1️⃣ Backend (`SnakeGuard_backend`)

### Changes Made
| File | Change | Reason |
|------|--------|--------|
| `main.py` | **Imported** `fastapi.middleware.cors.CORSMiddleware`. | Enables CORS for all origins, methods, and headers – required for Flutter Web. |
| `main.py` | **Added** `app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])`. | Prevents CORS blocking when the Flutter app sends requests from `http://localhost`. |
| `main.py` | **Created** `/predict` endpoint (POST) that delegates to a shared helper `_process_image`. | Standardizes the endpoint name expected by the Flutter frontend. |
| `main.py` | **Kept** legacy `/analyze` endpoint for backward compatibility, also delegating to `_process_image`. | No breaking change for any existing clients. |
| `main.py` | **Extracted** image‑processing logic into `_process_image`. It validates the uploaded file is an image, reads the bytes, calls `SnakeGuardAgent.run_loop`, and returns the resulting JSON. | Centralises logic, reduces duplication, and guarantees a JSON‑serialisable response that matches the Flutter data model. |
| `main.py` | **Improved error handling** – HTTP 400 for non‑image uploads, HTTP 500 for internal errors with logging. | Provides clear, consistent error messages to the client. |

### Result
- The FastAPI server now listens on `http://localhost:8000`.
- The `/predict` route accepts a multipart image (`file` field) and returns a JSON payload with keys such as `species`, `danger_level`, `description`, and `hospitals`.
- CORS headers are present on every response, eliminating browser‑side “CORS policy” blocks.

## 2️⃣ Frontend (`SnakeGuard_flutter`)

### Changes Made
| File | Change | Reason |
|------|--------|--------|
| `lib/data/services/api_service.dart` | **Added** `import 'dart:typed_data';`. | Needed for handling byte data. |
| `api_service.dart` | **Replaced** `http.MultipartFile.fromPath` with `http.MultipartFile.fromBytes` using `await image.readAsBytes()` and `filename: image.name`. | `MultipartFile.fromPath` relies on `dart:io` and fails on Web; `fromBytes` works on all platforms. |
| `api_service.dart` | Confirmed `baseUrl = "http://localhost:8000"` and request URL `'$baseUrl/predict'`. | Guarantees the request hits the newly created backend endpoint. |
| UI (image preview) | Already updated to use `Image.memory` with `kIsWeb` guard. | Ensures image preview works on Chrome without `File` usage. |

### Result
- Image selection on the web reads the file as bytes, builds a multipart request compatible with Flutter Web, and posts to `/predict`.
- No “Unsupported operation: MultipartFile is only supported where dart:io is available” errors.
- The JSON response is decoded into `ScanResult` exactly as the UI expects.

## 3️⃣ Verification Steps

1. **Start Backend**  
   ```bash
   cd AI-Hackathone/SnakeGuard_backend
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload



Work‑plan

#	Change	Rationale
1	Add import 'package:flutter/foundation.dart' show kIsWeb; and import 'dart:typed_data';	Needed for platform detection and to hold the image bytes that will be shown on the web.
2	Add a new field final Uint8List? imageBytes; to AnalysisResultsScreen	Image.memory requires a Uint8List. The previous screen already reads the image as bytes, so we expose them via the constructor.
3	Update the widget constructor to accept imageBytes (optional)	Allows the calling screen to pass the captured image bytes; the field is optional for mobile where Image.file is still used.
4	Replace the Image.file widget with a platform‑aware conditional:
kIsWeb ? Image.memory(widget.imageBytes ?? Uint8List(0)) : Image.file(File(widget.imagePath))	Prevents the runtime assertion !kIsWeb - Image.file is not supported on Flutter Web.
5	Keep the rest of the layout unchanged	Only the image rendering logic is changed; all other UI elements remain identical.
