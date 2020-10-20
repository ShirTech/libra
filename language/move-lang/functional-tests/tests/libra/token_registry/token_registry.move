//! account: bob
//! account: alice


// Defining the ACoin module so we can test its registry
//! new-transaction
//! sender: bob
module ACoin {
    use 0x1::TokenRegistry;
    use 0x1::Signer;

    struct ACoin {}

    public fun register(account: &signer) {
        assert(Signer::address_of(account) == {{bob}}, 8000);

        let a_coin = ACoin{};
        TokenRegistry::register<ACoin>(account, &a_coin, true)
    }
  }
// check: "Keep(EXECUTED)"


// should failed due to un-initialized counter
//! new-transaction
//! sender: bob
script {
    use {{bob}}::ACoin;

    fun main(sender: &signer) {
        ACoin::register(sender);
    }
}
// check: "ABORTED { code: 261"



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

// failure when trying to re-initialize the global counter
//! new-transaction
//! sender: libraroot
script {
    use 0x1::TokenRegistry;
    fun main(account: &signer)  {
        TokenRegistry::initialize(account);
    }
}
// check: "ABORTED { code: 262"



// should now succeed (after initialization)
//! new-transaction
//! sender: bob
script {
    use {{bob}}::ACoin;

    fun main(sender: &signer) {
        ACoin::register(sender);
    }
}
// check: "Keep(EXECUTED)"



// Defining the BCoin module so we can test increment of unique id (tested through prints)
//! new-transaction
//! sender: alice
module BCoin {
    use 0x1::TokenRegistry;
    use 0x1::Signer;

    struct BCoin {}

    public fun register(account: &signer) {
        assert(Signer::address_of(account) == {{alice}}, 8000);

      let b_coin = BCoin{};
      TokenRegistry::register<BCoin>(account, &b_coin, true)
    }
  }
// check: "Keep(EXECUTED)"


// Bob should fail registering alice's token
//! new-transaction
//! sender: bob
script {
    use {{alice}}::BCoin;

    fun main(sender: &signer) {
        BCoin::register(sender);
    }
}
// check: "ABORTED { code: 8000"


/// assert BCoin is not registered at alice
//! new-transaction
//! sender: alice
script {
    use {{alice}}::BCoin::BCoin;
    use 0x1::TokenRegistry;
    fun main() {
        TokenRegistry::assert_is_registered_at<BCoin>({{alice}});
    }
}
// check: "ABORTED { code: 517"


// Alice registers Bcoin
//! new-transaction
//! sender: alice
script {
    use {{alice}}::BCoin;

    fun main(sender: &signer) {
        BCoin::register(sender);
    }
}
// check: "Keep(EXECUTED)"


/// assert BCoin is registered at alice
//! new-transaction
//! sender: alice
script {
    use {{alice}}::BCoin::BCoin;
    use 0x1::TokenRegistry;
    fun main() {
        TokenRegistry::assert_is_registered_at<BCoin>({{alice}});
    }
}
// check: "Keep(EXECUTED)"


/// assert BCoin is transferable
//! new-transaction
//! sender: alice
script {
    use {{alice}}::BCoin::BCoin;
    use 0x1::TokenRegistry;
    fun main() {
        let is_transferable = TokenRegistry::is_transferable<BCoin>({{alice}});
        assert(is_transferable, 8000)
    }
}
// check: "Keep(EXECUTED)"


/// assert ACoin and BCoin have unique ids
//! new-transaction
//! sender: alice
script {
    use {{bob}}::ACoin::ACoin;
    use {{alice}}::BCoin::BCoin;
    use 0x1::TokenRegistry;
    fun main() {
        let a_id = TokenRegistry::get_id<ACoin>({{bob}});
        let b_id = TokenRegistry::get_id<BCoin>({{alice}});
        assert(a_id!=b_id, 8000)
    }
}
// check: "Keep(EXECUTED)"


// Alice cannot register Bcoin twice
//! new-transaction
//! sender: alice
script {
    use {{alice}}::BCoin;
    fun main(sender: &signer) {
        BCoin::register(sender);
    }
}
// check: "ABORTED { code: 518"
