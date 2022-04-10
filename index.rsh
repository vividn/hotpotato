'reach 0.1';


const Player = {
  informTimeout: Fun([], Null),
  waitForPass: Fun([], Null),
  acceptWager: Fun([UInt], Null),
}


export const main = Reach.App(() => {
  const Moderator = Participant('Moderator', {
    ...hasRandom,
    wager: UInt
  })

  const A = Participant('Alice', {
    ...Player,
  });
  
  const B = Participant('Bob', {
    ...Player,
  });
  init();
  
  const informTimeout = () => {
    each([A, B], () => {
      interact.informTimeout();
    });
  };

  // Moderator publishes the price to pay
  Moderator.only(() => {
    const wager = declassify(interact.wager);
  });
  Moderator.publish(wager);
  commit();

  // Alice makes a wager and then makes the contract
  A.only(() => {
    interact.acceptWager(wager)
  })
  A.pay(wager);
  commit();

  // Bob needs to accept the wager
  B.only(() => {
    interact.acceptWager(wager);
  })
  B.pay(wager);
  commit();

  // Moderator creates a hidden timer
  Moderator.only(() => {
    const _timer = interact.random() % 10 + 5
    const [_commitTimer, _saltTimer] = makeCommitment(interact, _timer);
    const commitTimer = declassify(_commitTimer);
  })
  Moderator.publish(commitTimer);
  
  const [ timeRemaining, keepGoing ] = makeDeadline(_timer);
  
  var AHasPotato = true;
  invariant( balance() == 2 * wager );
  while ( keepGoing() ) {
    if (AHasPotato) {
      commit();
      A.only(() => {
        interact.waitForPass()
      })
      A.publish().timeout(timeRemaining(), () => closeTo(B, informTimeout))
    } else {
      commit();
      B.only(() => {
        interact.waitForPass()
      })
      B.publish().timeout(timeRemaining(), () => closeTo(A, informTimeout));
    }
    AHasPotato = !AHasPotato
    continue;
  }
  transfer(2 * wager).to(AHasPotato ? B : A)
  commit();

  exit();
});
