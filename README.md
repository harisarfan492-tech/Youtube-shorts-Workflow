# YouTube Shorts Workflow

A Windows-based YouTube Shorts automation workflow built with n8n, Google Gemini, Edge TTS, FFmpeg, and the YouTube Data API.

## What it does

1. Starts manually in n8n.
2. Uses Gemini to write a short technology, computing, gaming, or science narration.
3. Saves the narration to a local text file.
4. Runs a Windows batch script to generate voice audio, captions, an opening hook, and the final vertical video.
5. Uploads the rendered video to YouTube.

## Repository contents

- `n8n/youtube_shorts_workflow.json`: credential-free n8n workflow export.
- `make_short.bat`: local video-rendering and audio-generation pipeline.
- `make_hook.ps1`: opening-hook text generator.
- `.gitignore`: excludes generated media and local secrets.

## Requirements

- Windows
- n8n with the Google Gemini and YouTube nodes available
- Google Gemini API access
- A connected YouTube OAuth2 credential in n8n
- Python and the `edge-tts` package
- FFmpeg installed at the path configured in `make_short.bat`

Install Edge TTS:

```powershell
py -m pip install edge-tts
```

## Gameplay clips

You need to provide gameplay/source clips yourself, or generate them from a longer video with FFmpeg.

The batch script randomly selects from 30 clips named `clip_01.mp4` through `clip_30.mp4` inside:

```text
C:\n8n-content\clips
```

**Option 1: Provide your own clips**

Put at least 30 suitable video clips in the `clips` folder and name them `clip_01.mp4`, `clip_02.mp4`, ... `clip_30.mp4`.

**Option 2: Split one longer video with FFmpeg**

Place a source video in your project folder, create the `clips` folder if it does not exist, then run this command once in Command Prompt (change `source.mp4` to your video's filename):

```bat
ffmpeg -i "C:\n8n-content\source.mp4" -map 0:v:0 -map 0:a? -c:v libx264 -preset veryfast -crf 23 -c:a aac -b:a 128k -f segment -segment_time 45 -reset_timestamps 1 -segment_start_number 1 "C:\n8n-content\clips\clip_%%02d.mp4"
```

This creates sequential clips of approximately 45 seconds, named `clip_01.mp4`, `clip_02.mp4`, and so on. The batch script currently chooses randomly from the first 30 filenames, so make sure the source video is long enough to produce at least 30 clips. Use footage you have permission to use.

## Setup

1. Install FFmpeg and Edge TTS.
2. Create the project folders: `audio`, `clips`, and `output`.
3. Add your own gameplay clips to `clips`, using the naming convention above, or generate them with the FFmpeg command.
4. Place `make_short.bat` and `make_hook.ps1` in your project root.
5. Import `n8n/youtube_shorts_workflow.json` into n8n.
6. Open the Gemini node and select your own Google Gemini credential.
7. Open the YouTube upload node and select your own YouTube OAuth2 credential.
8. Review the Windows paths in the workflow and scripts. The exported workflow currently expects `C:\\n8n-content`; adjust them if your project is elsewhere.
9. Run the workflow manually.

## Important notes

- This project is configured for Windows and is not a one-click cross-platform setup.
- The workflow JSON contains no API keys or OAuth tokens. You must connect your own credentials in n8n.
- The workflow uploads to YouTube. Check the YouTube node's upload/privacy settings and test carefully before using it on a live channel.
- Generated media, source videos, audio, credentials, and local n8n data should not be committed.

## License

No license has been added yet. Until a license is chosen, normal copyright applies and reuse is not automatically permitted.

## Needed Improvements

Some improvements can be made to the captions in the 'make_short.bat' file since the current captions look rather terrible, just added as a placehoder, if you want to see the quality of content you can do so at 
https://youtube.com/shorts/U-izKHQTJ_U
