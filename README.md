## DailySort: A Fun Word Game to learn a new English word, everyday!

<p align="center">
  <img src="https://github.com/user-attachments/assets/12cbcde7-8c90-4220-a996-e5099d634b7a" width=150>
  <img src="https://github.com/user-attachments/assets/46962c85-71e7-402a-b2e3-fe61ffbe328c" width=150>
  <img src="https://github.com/user-attachments/assets/9be1f060-c054-47c2-8ddb-e4d84e4c46d8" width=150>
  <img src="https://github.com/user-attachments/assets/bc05bcd3-d735-4bec-b2cf-6475a00488a3" width=150>
  <img src="https://github.com/user-attachments/assets/4bdfc575-34e9-4a67-82f5-643f8439d10c" width=150>
</p>

<p align="center">
  <a href="https://apps.apple.com/de/app/dailysort/id6739777889?l=en-GB">
    <img src="https://github.com/user-attachments/assets/e4732591-a53e-430d-9355-e75984a85edf" width=160>
  </a>
</p>

- Rearrange Letters: Unscramble the daily word by sorting the tiles.
- Interactive Hints: Tile colors give you clues about how close you are to the correct word.
- Learn as You Play: Guess the word correctly to unlock its meaning!
- Daily Challenge: A fresh word puzzle every day to keep you engaged.
-------
![Data Flow](https://github.com/user-attachments/assets/a2cc1eaa-9730-4481-945e-b0a31154977d)

### `WordRepository`:
  Around 3,000 words are saved in a JSON file. The responsibility of WordRepository is to parse the JSON and return all available words.

### `WordStorageModelContext`:
  The responsibility of this class is to save the words played by users and return the list of all played words.
  
### `WordProviderUseCase`:
  This use case uses `WordRepository` and `WordStorageModelContext` to provide a word for the game.
First, it fetches `allWords` and `storedWords`. If the last word saved in `saveWords` was played today, it returns `noWordToday`.
Otherwise, it subtracts `storedWords` from `allWords` to avoid playing a word twice and picks a word from the remaining `allWords`.
To avoid fetching `allWords` and `storedWords` repeatedly, it stores the selected word in `UserSettings` until the player has played it.

### `AppTriggerFactory`:
It returns a `Publisher<Void>`, which helps us reload specific parts of the app in response to events, such as when the app becomes active or the player guesses the word.

