import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);


// const isBob = await ask.ask(
//   `Bake a hot potato?`,
//   ask.yesno
// );
// const who = isAlice ? 'Alice' : 'Bob';

// console.log(`You are playing as ${who}`)

  const startingBalance = stdlib.parseCurrency(100);

  const [ accAlice, accBob ] =
    await stdlib.newTestAccounts(2, startingBalance);
  console.log('Hello, Alice and Bob!');

  console.log('Launching...');
  const ctcAlice = accAlice.contract(backend);
  const ctcBob = accBob.contract(backend, ctcAlice.getInfo());

  const fmt = (x) => stdlib.formatCurrency(x, 4);
  const getBalance = async (acc) => fmt(await stdlib.balanceOf(acc));
  const displayBalances = async () => {
    console.log(`Alice has ${await getBalance(accAlice)}`);
    console.log(`Bob has ${await getBalance(accBob)}`)
  }



  await displayBalances();
  await Promise.all([
    backend.Alice(ctcAlice, {
      ...stdlib.hasRandom,
      wager: stdlib.parseCurrency(10),
      informTimeout: () => {
        console.log("Alice saw timeout")
      },
      waitForPass: async () => {
        console.log("Alice has potato")
        await setTimeout(console.log("Alice passes to Bob", 2000))
      },
    }),
    backend.Bob(ctcBob, {
      ...stdlib.hasRandom,
      acceptWager: (amount) => {
        console.log(`Bob accepts wager of ${amount}`)
      },
      informTimeout: () => {
        console.log("Bob saw timeout")
      },
      waitForPass: async () => {
        console.log("Bob has potato")
        await setTimeout(console.log("Bob passes to Alice", 1000))
      }
    }),
  ]);
  console.log("game over")
  await displayBalances();

  console.log('Goodbye, Alice and Bob!');
