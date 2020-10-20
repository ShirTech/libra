//! account: alice

//! new-transaction
module Holder {
    resource struct Holder<T> { x: T }
    public fun hold<T>(account: &signer, x: T)  {
        move_to(account, Holder<T> { x })
    }
}
// check: "Keep(EXECUTED)"


//! new-transaction
//! sender: alice
module ACoin {
    use 0x1::TokenRegistry;
    use 0x1::Signer;

    struct ACoin {}

    public fun register(account: &signer) {
        assert(Signer::address_of(account) == {{alice}}, 8000);
        let a_coin = ACoin{};
        TokenRegistry::register<ACoin>(account, &a_coin, true)
    }
  }
// check: "Keep(EXECUTED)"


// initializing the global counter
//! new-transaction
//! sender: libraroot
script {
    use 0x1::TokenRegistry;
    fun main(account: &signer)  {
        TokenRegistry::initialize(account);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: alice
script {
    use {{alice}}::ACoin;

    fun main(sender: &signer) {
        ACoin::register(sender);
    }
}
// check: "Keep(EXECUTED)"


// first try- minting
//! new-transaction
//! sender: alice
script {
    use {{alice}}::ACoin::ACoin;
    use 0x1::TokenRegistry;
    use 0x1::Libra;
    use {{default}}::Holder;

    fun main(sender: &signer) {
        let a_coin = TokenRegistry::create<ACoin>(sender,10000);
        assert(Libra::value<ACoin>(&a_coin) == 10000, 0);


        let (a_coin, a_coin2) = Libra::split(a_coin, 5000);
        assert(Libra::value<ACoin>(&a_coin) == 5000 , 0);
        assert(Libra::value<ACoin>(&a_coin2) == 5000 , 2);
        let tmp = Libra::withdraw(&mut a_coin, 1000);
        assert(Libra::value<ACoin>(&a_coin) == 4000 , 4);
        assert(Libra::value<ACoin>(&tmp) == 1000 , 5);
        Libra::deposit(&mut a_coin, tmp);
        assert(Libra::value<ACoin>(&a_coin) == 5000 , 6);
        let a_coin = Libra::join(a_coin, a_coin2);
        assert(Libra::value<ACoin>(&a_coin) == 10000, 7);


        Holder::hold(sender, a_coin);
    }
}
// check: "Keep(EXECUTED)"