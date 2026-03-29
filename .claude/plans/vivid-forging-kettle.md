# Plan: Voice-Enabled AI Chatbot with Speech Support

## Context
User wants to enhance the AI chatbot experience by adding:
- **Speech-to-text:** User speaks → converted to text
- **AI processing:** Text sent to OpenRouter (Gemma 3 12B) → AI response
- **Text-to-speech:** AI response spoken aloud to user
- Goal: Natural, human-like conversation via voice

Current chatbot (`Chatbot.dart`) is a WebView. We'll create a new native chatbot screen.

---

## Dependencies to Add (pubspec.yaml)

```yaml
dependencies:
  speech_to_text: ^6.3.0      # Speech recognition
  flutter_tts: ^3.8.3         # Text-to-speech
  http: ^1.5.0               # Already exists - for API calls
```

---

## Platform Permissions

### Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (`ios/Runner/Info.plist`):
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition to convert your voice to text for the AI chatbot.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice chat with the AI assistant.</string>
```

---

## New File: `lib/voice_chatbot_screen.dart`

### Architecture

**State Management:**
- `_messages`: List of chat messages (user + AI)
- `_isListening`: Speech recognition active
- `_isSpeaking`: TTS currently playing
- `_speechEnabled`: Whether speech recognition is available
- `_speechToText`: SpeechToText instance
- `_flutterTts`: FlutterTts instance
- `_textController`: For manual text input fallback

**UI Layout:**
```
Scaffold
├─ AppBar: "AI Voice Assistant"
├─ Column
│  ├─ Expanded (flex: 8)
│  │   └─ ListView.builder (messages)
│  │       ├─ User message (right-aligned bubble)
│  │       └─ AI message (left-aligned bubble)
│  └─ Container (input area)
│      ├─ TextField (manual input)
│      ├─ IconButton: Mic (start/stop listening)
│      ├─ IconButton: Speaker (play response)
│      └─ Send button
```

**Message Model:**
```dart
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
}
```

### Core Methods

1. **`_initSpeech()`** - Initialize speech recognizer
2. **`_startListening()`** - Activate microphone, listen for speech
3. **`_stopListening()`** - Stop recognition, get final text
4. **`_speak(String text)`** - Convert AI response to speech
5. **`_stopSpeaking()`** - Cancel ongoing TTS
6. **`_sendMessage(String text)`** - Send text to OpenRouter API
7. **`_callOpenRouter(String message)`** - HTTP POST to OpenRouter with Gemma 3 12B

### OpenRouter API Integration

**Endpoint:** `https://openrouter.ai/api/v1/chat/completions`

**Headers:**
```dart
{
  'Authorization': 'Bearer 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',
  'HTTP-Referer': 'https://manoveda.app', // Your app's URL
  'X-Title': 'Manoveda AI', // Your app name
  'Content-Type': 'application/json',
}
```

**Body:**
```dart
{
  "model": "google/gemma-3-12b-it:free",
  "messages": [
    {"role": "system", "content": "You are a supportive mental wellness assistant. Be empathetic, gentle, and helpful."},
    {"role": "user", "content": userMessage}
  ],
  "stream": false
}
```

**Response parsing:**
```dart
response['choices'][0]['message']['content']
```

### Speech Recognition Flow

1. User taps mic button
2. Start listening (show "Listening..." indicator)
3. On speech result: show live transcription
4. On speech stop: send recognized text to AI
5. Display AI response, auto-play via TTS

### Text-to-Speech

- Configure `flutter_tts`:
  - Set speech rate (0.5-0.8 for natural pace)
  - Set volume (1.0)
  - Set pitch (1.0)
  - Choose language: `en-US` or `hi-IN` based on user preference
- Auto-speak AI responses (with toggle option to disable)
- Stop speaking when user starts speaking

---

## Files to Modify/Create

1. **`pubspec.yaml`** - Add `speech_to_text`, `flutter_tts`
2. **`lib/voice_chatbot_screen.dart`** - New screen (main implementation)
3. **`android/app/src/main/AndroidManifest.xml`** - Add `RECORD_AUDIO` permission
4. **`ios/Runner/Info.plist`** - Add `NSSpeechRecognitionUsageDescription` and `NSMicrophoneUsageDescription`
5. **`lib/homepage.dart`** - Change "AI Chatbot" tile to navigate to new voice chatbot (or add new tile)

---

## Implementation Order

1. Add dependencies and permissions
2. Create voice chatbot screen with basic UI
3. Implement OpenRouter API call
4. Add speech-to-text functionality
5. Add text-to-speech playback
6. Test on device
7. Update navigation to use new screen

---

## Testing Checklist

- [ ] Speech recognition works (tap mic, speak, see text)
- [ ] API call returns AI response
- [ ] TTS plays AI response aloud
- [ ] Manual text input still works
- [ ] Permissions flow correctly
- [ ] Can stop speech mid-playback
- [ ] UI updates during listening/speaking states

---

## Considerations

- **OpenRouter rate limits:** Free tier has limits, monitor usage
- **Speech recognition accuracy:** Depends on device and language
- **TTS quality:** Device TTS varies; could upgrade to cloud TTS later
- **Conversation history:** Currently stateless - each request independent. Could add context history.
- **Language support:** Gemini supports many languages; device STT/TTS may need locale config
- **Error handling:** Network failures, speech errors, permission denied

---

## Optional Future Enhancements

- Save chat history
- Multiple voice options (female/male)
- Adjustable TTS speed/pitch
- Conversation context memory
- Different AI personalities
- Voice activity detection (auto-detect speech end)
