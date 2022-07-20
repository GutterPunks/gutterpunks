// log
import store from "../store";

const fetchDataRequest = () => {
  return {
    type: "CHECK_DATA_REQUEST",
  };
};

const fetchDataSuccess = (payload) => {
  return {
    type: "CHECK_DATA_SUCCESS",
    payload: payload,
  };
};

const fetchDataFailed = (payload) => {
  return {
    type: "CHECK_DATA_FAILED",
    payload: payload,
  };
};

export const fetchData = (blockchainAccount) => {
  return async (dispatch) => {
    dispatch(fetchDataRequest());
    try {

    console.log("https://api.gutterpunks.xyz/asset/read.php?owner=" + blockchainAccount);
    const assets_abiResponse = await fetch("https://api.gutterpunks.xyz/asset/read.php?owner=" + blockchainAccount, {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    });
    const assets = await assets_abiResponse.json();
    const configResponse = await fetch("/config/config.json", {
      headers: { "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": "true",
        "Access-Control-Allow-Methods": "GET,HEAD,OPTIONS,POST,PUT",
        "Access-Control-Allow-Headers": "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers",
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    });
    const CONFIG = await configResponse.json();
    
      let isApprovedForAll = await store
        .getState()
        .blockchain.gp_smartContract.methods.isApprovedForAll(blockchainAccount, CONFIG.OMNI_CONTRACT_ADDRESS)
        .call();

      console.log("Is approved for all? " + isApprovedForAll);

      dispatch(
        fetchDataSuccess({
          assets,
          isApprovedForAll,
        })
      );
    } catch (err) {
      console.log(err);
      dispatch(fetchDataFailed("Could not load data from contract."));
    }
  };
};
