import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Time "mo:base/Time";

import ExperimentalCycles "mo:base/ExperimentalCycles";

import ICRC1 "./ICRC1";
import Array "mo:base/Array";

shared ({ caller = _owner }) actor class Token(
    name : Text,
    symbol : Text,
) : async ICRC1.FullInterface {

    stable let minting_account : ICRC1.Account = {
        owner = _owner;
        subaccount = null;
    };

    let token_args : ICRC1.TokenInitArgs = {
        advanced_settings = null;
        decimals = 18;
        fee = 1_000;
        initial_balances = [(
            {
                owner = _owner;
                subaccount = null;
            },
            0,
        )];
        min_burn_amount = 0;
        minting_account = null;
        name = name;
        symbol = symbol;
    };

    stable let token = ICRC1.init({
        token_args with minting_account = Option.get(
            token_args.minting_account,
            minting_account,
        );
    });

    /// Functions for the ICRC1 token standard
    public shared query func icrc1_name() : async Text {
        ICRC1.name(token);
    };

    public shared query func icrc1_symbol() : async Text {
        ICRC1.symbol(token);
    };

    public shared query func icrc1_decimals() : async Nat8 {
        ICRC1.decimals(token);
    };

    public shared query func icrc1_fee() : async ICRC1.Balance {
        ICRC1.fee(token);
    };

    public shared query func icrc1_metadata() : async [ICRC1.MetaDatum] {
        ICRC1.metadata(token);
    };

    public shared query func icrc1_total_supply() : async ICRC1.Balance {
        ICRC1.total_supply(token);
    };

    public shared query func icrc1_minting_account() : async ?ICRC1.Account {
        ?ICRC1.minting_account(token);
    };

    public shared query func icrc1_balance_of(args : ICRC1.Account) : async ICRC1.Balance {
        ICRC1.balance_of(token, args);
    };

    public shared query func icrc1_supported_standards() : async [ICRC1.SupportedStandard] {
        ICRC1.supported_standards(token);
    };

    public shared ({ caller }) func icrc1_transfer(args : ICRC1.TransferArgs) : async ICRC1.TransferResult {
        await* ICRC1.transfer(token, args, caller);
    };

    public shared ({ caller }) func mint(account : Principal, amount : ICRC1.Balance) : async ICRC1.TransferResult {
        let to_account : ICRC1.Account = {
            owner = account;
            subaccount = null;
        };
        let args = {
            to = to_account;
            amount = amount;
            memo = null;
            created_at_time = null;
        };
        await* ICRC1.mint(token, args, caller);
    };

    public shared ({ caller }) func burn(args : ICRC1.BurnArgs) : async ICRC1.TransferResult {
        await* ICRC1.burn(token, args, caller);
    };

    // Functions from the rosetta icrc1 ledger
    public shared query func get_transactions(req : ICRC1.GetTransactionsRequest) : async ICRC1.GetTransactionsResponse {
        ICRC1.get_transactions(token, req);
    };

    // Additional functions not included in the ICRC1 standard
    public shared func get_transaction(i : ICRC1.TxIndex) : async ?ICRC1.Transaction {
        await* ICRC1.get_transaction(token, i);
    };

    // Deposit cycles into this archive canister.
    public shared func deposit_cycles() : async () {
        let amount = ExperimentalCycles.available();
        let accepted = ExperimentalCycles.accept(amount);
        assert (accepted == amount);
    };
};
