import hanzi from 'hanzi';
import fs from 'fs';

const characters = [];

hanzi.start();

for (let i = 1; i < 2501; i++) {
  const character = hanzi.getCharacterInFrequencyListByPosition(i);

  characters.push(character);
}

fs.writeFileSync('tmp/hanzi.json', JSON.stringify(characters, null, 2));
