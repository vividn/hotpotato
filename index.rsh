'reach 0.1';


const Player = {
  informTimeout: Fun([], Null),
  waitForPass: Fun([], Null),
}


export const main = Reach.App(() => {
  const A = Participant('Alice', {
    ...Player,
    wager: UInt,
  });
  
  const B = Participant('Bob', {
    ...Player,
    acceptWager: Fun([UInt], Null)
  });
  init();
  
  const informTimeout = () => {
    each([A, B], () => {
      interact.informTimeout();
    });
  };

  // Alice makes a wager and then makes the contract
  A.only(() => {
    const wager = declassify(interact.wager)
  })
  A.publish(wager)
    .pay(wager);
  commit();

  // Bob needs to accept the wager
  B.only(() => {
    interact.acceptWager(wager);
  })
  B.pay(wager)
  
  const [ timeRemaining, keepGoing ] = makeDeadline(10);
  
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
