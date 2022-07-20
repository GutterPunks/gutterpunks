// constants
import WalletConnectProvider from "@walletconnect/web3-provider";
import WalletLink from "walletlink";
import Web3EthContract from "web3-eth-contract";
import Web3 from "web3";
import Web3Modal from "web3modal";

// log
import { fetchData } from "../data/dataActions";

const providerOptions = {
  walletconnect: {
    package: WalletConnectProvider, // required
    options: {
      infuraId: "00a7e092c51b42fd94c19d2c88541889" // required
    }
  }, 
  walletlink: {
    package: WalletLink, // Required
    options: {
      appName: "Gutter Punks Omnichain", // Required
      infuraId: "00a7e092c51b42fd94c19d2c88541889", // Required unless you provide a JSON RPC url; see `rpc` below
      rpc: "", // Optional if `infuraId` is provided; otherwise it's required
      chainId: 1, // Optional. It defaults to 1 if not provided
      appLogoUrl: null, // Optional. Application logo image URL. favicon is used if unspecified
      darkMode: false // Optional. Use dark theme, defaults to false
    }
  }
};

const web3Modal = new Web3Modal({
  network: "mainnet", // optional
  providerOptions,
  theme: "dark"
});

const connectRequest = () => {
  return {
    type: "CONNECTION_REQUEST",
  };
};

const connectSuccess = (payload) => {
  return {
    type: "CONNECTION_SUCCESS",
    payload: payload,
  };
};

const connectFailed = (payload) => {
  return {
    type: "CONNECTION_FAILED",
    payload: payload,
  };
};

const updateAccountRequest = (payload) => {
  return {
    type: "UPDATE_ACCOUNT",
    payload: payload,
  };
};

export const connect = () => {
  return async (dispatch) => {
    dispatch(connectRequest());
    const gp_abiResponse = await fetch("/config/gp_abi.json", {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    });
    const omni_abiResponse = await fetch("/config/omni_abi.json", {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    });
    const endpoint_abiResponse = await fetch("/config/endpoint_abi.json", {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    });
    const gp_abi = await gp_abiResponse.json();
    const omni_abi = await omni_abiResponse.json();
    const endpoint_abi = await endpoint_abiResponse.json();
    const configResponse = await fetch("/config/config.json", {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    });
    const CONFIG = await configResponse.json();
    web3Modal.clearCachedProvider();
    const provider = await web3Modal.connect();
    const web3 = new Web3(provider);

    const { ethereum } = web3;
      Web3EthContract.setProvider(provider);
      try {
        const accounts = await web3.eth.getAccounts();
        const networkId = await web3.eth.net.getId();
        if (networkId == CONFIG.NETWORK.ID) {
          const gp_SmartContractObj = new Web3EthContract(
            gp_abi,
            CONFIG.GP_CONTRACT_ADDRESS
          );
          const omni_SmartContractObj = new Web3EthContract(
            omni_abi,
            CONFIG.OMNI_CONTRACT_ADDRESS
          );
          const endpoint_SmartContractObj = new Web3EthContract(
            endpoint_abi,
            CONFIG.ENDPOINT_CONTRACT_ADDRESS
          );
          dispatch(
            connectSuccess({
              account: accounts[0],
              gp_smartContract: gp_SmartContractObj,
              omni_smartContract: omni_SmartContractObj,
              endpoint_smartContract: endpoint_SmartContractObj,
              web3: web3,
            })
          );
          // Add listeners start
          provider.on("accountsChanged", (accounts) => {
            dispatch(updateAccount(accounts[0]));
          });
          provider.on("chainChanged", () => {
            window.location.reload();
          });
          // Add listeners end
        } else {
          dispatch(connectFailed(`Change network to ${CONFIG.NETWORK.NAME}.`));
        }
      } catch (err) {
        dispatch(connectFailed("Something went wrong."));
      }
    }
};

export const updateAccount = (account) => {
  return async (dispatch) => {
    dispatch(updateAccountRequest({ account: account }));
    dispatch(fetchData(account));
  };
};
