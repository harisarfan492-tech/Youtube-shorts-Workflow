# YouTube Shorts Workflow

A Windows-based YouTube Shorts automation workflow built with n8n, Google Gemini, Python Edge TTS, FFmpeg, and the YouTube Data API.

## What it does

1. Starts manually in n8n.
2. Uses Gemini to write a short technology, computing, gaming, or science narration.
3. Saves the narration to a local text file.
4. Runs a Windows batch script to generate voice audio, captions, an opening hook, and the final vertical video.
5. Uploads the rendered video to YouTube.

## Repository contents

- `n8n/youtube_shorts_workflow.json`: credential-free n8n workflow export.
- `make_short.bat`: local video-rendering pipeline (add this file to the project root).
- `make_hook.ps1`: opening-hook text generator (add this file to the project root).

> The two rendering scripts are not included in this initial repository commit. Add the exact working copies from your project folder before treating the repository as a complete runnable release.

## Requirements

- Windows
- n8n with the Google Gemini and YouTube nodes available
- Google Gemini API access
- A connected YouTube OAuth2 credential in n8n
- Python and the `edge-tts` package
- FFmpeg installed and available at the path configured in `make_short.bat`

Install Edge TTS:

```powershell
py -m pip install edge-tts
```

## Setup

1. Import `n8n/youtube_shorts_workflow.json` into n8n.
2. Open the Gemini node and select your own Google Gemini credential.
3. Open the YouTube upload node and select your own YouTube OAuth2 credential.
4. Place `make_short.bat` and `make_hook.ps1` in your project root.
5. Review the Windows paths in the workflow and scripts. The exported workflow currently expects `C:\\n8n-content`; adjust them if your project is elsewhere.
6. Ensure the expected folders exist: `audio`, `clips`, and `output`. Add your own source gameplay clips under the clip naming convention expected by the batch script.
7. Run the workflow manually.

## Important notes

- This workflow is configured for Windows and is not a one-click cross-platform setup.
- The workflow JSON contains no API keys or OAuth tokens. You must connect your own credentials in n8n.
- The workflow uploads to YouTube. Test with a private/unlisted upload configuration before using it on a live channel.
- Generated media, source videos, audio, credentials, and local n8n data should not be committed.

## License

No license has been added yet. Until a license is chosen, normal copyright applies and reuse is not automatically permitted.
