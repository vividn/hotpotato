'reach 0.1';


const Player = {
  informTimeout: Fun([], Null),
  waitForPass: Fun([], Null),
}

const informTimeout = () => {
  each([Alice, Bob], () => {
    interact.informTimeout();
  });
};

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
  commit();

  const [ timeRemaining, keepGoing ] = makeDeadline(10);

  invariant( balance() == 2 * wager );
  while ( keepGoing() ) {
    A.only(() => {
      interact.waitForPass()
    })
    A.publish().timeout(timeRemaining(), () => closeTo(B, informTimeout))
    commit()

    B.only(() => {
      interact.waitForPass()
    })
    B.publish().timeout(timeRemaining(), () => closeTo(A, informTimeout))
    commit();

    continue;
  }
  // write your program here
  exit();
});
