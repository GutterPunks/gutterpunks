import React, { useEffect, useState, useRef } from "react";
import { useDispatch, useSelector } from "react-redux";
import { connect } from "./redux/blockchain/blockchainActions";
import { fetchData } from "./redux/data/dataActions";
import * as s from "./styles/globalStyles";
import styled from "styled-components";

const truncate = (input, len) =>
  input.length > len ? `${input.substring(0, len)}...` : input;

export const StyledButton = styled.button`
  padding: 10px;
  border-radius: 50px;
  border: none;
  background-color: var(--secondary);
  padding: 10px;
  font-weight: bold;
  color: var(--secondary-text);
  width: 100px;
  cursor: pointer;
  box-shadow: 0px 6px 0px -2px rgba(250, 250, 250, 0.3);
  -webkit-box-shadow: 0px 6px 0px -2px rgba(250, 250, 250, 0.3);
  -moz-box-shadow: 0px 6px 0px -2px rgba(250, 250, 250, 0.3);
  :active {
    box-shadow: none;
    -webkit-box-shadow: none;
    -moz-box-shadow: none;
  }
`;

export const StyledTraverseButton = styled.button`
  padding: 10px;
  border-radius: 50px;
  border: none;
  background-color: #EC5800;
  padding: 10px;
  font-weight: bold;
  color: var(--secondary-text);
  width: 100px;
  cursor: pointer;
  box-shadow: 0px 6px 0px -2px rgba(250, 250, 250, 0.3);
  -webkit-box-shadow: 0px 6px 0px -2px rgba(250, 250, 250, 0.3);
  -moz-box-shadow: 0px 6px 0px -2px rgba(250, 250, 250, 0.3);
  :active {
    box-shadow: none;
    -webkit-box-shadow: none;
    -moz-box-shadow: none;
  }
`;

export const StyledRoundButton = styled.button`
  padding: 20px;
  border-radius: 100%;
  border: none;
  background-color: var(--primary);
  padding: 10px;
  font-weight: bold;
  font-size: 15px;
  color: var(--accent-text);
  width: 50px;
  height: 50px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0px 4px 0px -2px rgba(250, 250, 250, 0.3);
  -webkit-box-shadow: 0px 4px 0px -2px rgba(250, 250, 250, 0.3);
  -moz-box-shadow: 0px 4px 0px -2px rgba(250, 250, 250, 0.3);
  :active {
    box-shadow: none;
    -webkit-box-shadow: none;
    -moz-box-shadow: none;
  }
`;

export const ResponsiveWrapper = styled.div`
  display: flex;
  flex: 1;
  flex-direction: column;
  justify-content: stretched;
  align-items: stretched;
  width: 100%;
  @media (min-width: 767px) {
    flex-direction: row;
  }
`;

export const StyledLogo = styled.img`
  width: 300px;
  @media (min-width: 767px) {
    width: 500px;
  }
  transition: width 0.5s;
  transition: height 0.5s;
`;

export const StyledImg = styled.img`
  box-shadow: 0px 5px 11px 2px rgba(0, 0, 0, 0.7);
  border: 4px dashed var(--secondary);
  background-color: var(--accent);
  border-radius: 100%;
  width: 200px;
  @media (min-width: 900px) {
    width: 250px;
  }
  @media (min-width: 1000px) {
    width: 300px;
  }
  transition: width 0.5s;
`;

export const StyledLink = styled.a`
  color: var(--secondary);
  text-decoration: none;
`;

function App() {
  const dispatch = useDispatch();
  const blockchain = useSelector((state) => state.blockchain);
  const data = useSelector((state) => state.data);
  const [traversingNFT, setTraversingNFT] = useState(false);
  const [feedback, setFeedback] = useState(``);
  const [tokenId, setTokenId] = useState(0);
  const [chainId, setChainId] = useState(2);
  const [traverseCostWei, setTraverseCostWei] = useState(0);
  const [CONFIG, SET_CONFIG] = useState({
    GP_CONTRACT_ADDRESS: "0x9a54988016E97Fdc388D1b084BcbfE32De91b70c",
    OMNI_CONTRACT_ADDRESS: "0xf689554c1bc3dC54152a271210eeF9f55979c4f6",
    ENDPOINT_CONTRACT_ADDRESS: "0x66A71Dcef29A0fFBDBE3c6a460a3B5BC225Cd675",
    NETWORK: {
      NAME: "Ethereum",
      SYMBOL: "ETH",
      ID: 1
    },
    TRAVERSAL_CHAINS: 
      [{
      NAME: "Binance",
      SYMBOL: "BSC",
      ID: 2 
      },{
      NAME: "Avalanche",
      SYMBOL: "AVAX",
      ID: 6 
      },{
      NAME: "Polygon",
      SYMBOL: "MATIC",
      ID: 9 
      },{
      NAME: "Arbitrum",
      SYMBOL: "ARB",
      ID: 10 
      },{
      NAME: "Optimism",
      SYMBOL: "OPT",
      ID: 11 
      },{
      NAME: "Fantom",
      SYMBOL: "FTM",
      ID: 12 
      }
    ],
    TRAVERSAL_GAS_LIMIT: 350000,
    SET_APPROVAL_GAS_LIMIT: 60000,
    SHOW_BACKGROUND: true
  });

  
  const traverseNFT = () => {
    let totalGasLimit = CONFIG.TRAVERSAL_GAS_LIMIT;
    setFeedback(`Traversing...`);
    setTraversingNFT(true);
    if(data.isApprovedForAll) {
      try { 
        blockchain.omni_smartContract.methods
          .traverseChains(chainId, document.getElementById('ddTokenId').value)
          .send({
            gasLimit: String(totalGasLimit),
            to: CONFIG.OMNI_CONTRACT_ADDRESS,
            from: blockchain.account,
            value: traverseCostWei,
          })
          .once("error", (err) => {
            console.log(err);
            setFeedback("Sorry, something went wrong please try again later.");
            setTraversingNFT(false);
          })
          .then((receipt) => {
            console.log(receipt);
            setFeedback(
              `Your traversal has begun!`
            );
            setTraversingNFT(false);
            dispatch(fetchData(blockchain.account));
          });
        } catch (err) {
          console.log(err);
          setFeedback("Sorry, something went wrong please try again later.");
          setTraversingNFT(false);
        }
    } else {
      setFeedback("Sorry, something went wrong please try again later.");
    }
  };

  
  const setApprovalForAll = () => {
    let totalGasLimit = CONFIG.SET_APPROVAL_GAS_LIMIT;
    setFeedback(`Setting Approval...`);
      try { 
        blockchain.gp_smartContract.methods
          .setApprovalForAll(CONFIG.OMNI_CONTRACT_ADDRESS, true)
          .send({
            gasLimit: String(totalGasLimit),
            to: CONFIG.GP_CONTRACT_ADDRESS,
            from: blockchain.account,
          })
          .once("error", (err) => {
            console.log(err);
            setFeedback("Sorry, something went wrong please try again later.");
          })
          .then((receipt) => {
            console.log(receipt);
            setFeedback(
              `Approval Set`
            );
            dispatch(fetchData(blockchain.account));
          });
        } catch (err) {
          console.log(err);
          setFeedback("Sorry, something went wrong please try again later.");
        }
  };

  const getData = () => {
    if (blockchain.account !== "" && blockchain.gp_smartContract !== null) {
      getConfig();
      updateTraverseCostWei(chainId);
      dispatch(fetchData(blockchain.account));
    }
  };

  const updateTokenId = (event)=>{
        // show the user input value to console
        const parsed = parseInt(event.target.value, 10);
        if(!isNaN(parsed) && parsed >= 1 && parsed <= 9999) {
          setTokenId(parsed);
        }
    };

  const updateChainId = (event)=>{
        // show the user input value to console
        const parsed = parseInt(event.target.value, 10);
        if(!isNaN(parsed) && (parsed == 2 || parsed == 6 || parsed == 9 || parsed == 10 || parsed == 12 || parsed == 11)) {
          setChainId(parsed);
          console.log("Update traverse cost...");
          updateTraverseCostWei(parsed);
        }
    };

  const getConfig = async () => {
    const configResponse = await fetch("/config/config.json", {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    });
    const config = await configResponse.json();
    SET_CONFIG(config);
  };

  const updateTraverseCostWei =  (t_chainId) => {    
        blockchain.endpoint_smartContract.methods.estimateFees(t_chainId, CONFIG.OMNI_CONTRACT_ADDRESS, "0x000000000000000000000000000000000000000000000000000000000000dead0000000000000000000000000000000000000000000000000000000000000001", false, "0x00010000000000000000000000000000000000000000000000000000000000055730").call()
          .then((receipt) => {
            console.log(receipt);
            setTraverseCostWei(receipt[0] * 1.5);
          });
  };

  useEffect(() => {
    getData();
  }, [blockchain.account]);

  return (
    <s.Screen>
      <s.Container
        flex={1}
        ai={"center"}
        style={{ padding: 24, backgroundColor: "var(--primary)" }}
        image={CONFIG.SHOW_BACKGROUND ? "/config/images/bg.png" : null}
      >
        <StyledLogo alt={"logo"} src={"/config/images/logo.png"} />
        <s.SpacerSmall />
        <ResponsiveWrapper flex={1} style={{ padding: 24 }} test>
          <s.SpacerLarge />
          <s.Container
            flex={2}
            jc={"center"}
            ai={"center"}
            style={{
              backgroundColor: "var(--accent)",
              padding: 24,
              borderRadius: 24,
              border: "4px var(--secondary)",
              boxShadow: "0px 5px 11px 2px rgba(0,0,0,0.7)",
            }}
          >
            <s.TextTitle
              style={{
                textAlign: "center",
                fontSize: 50,
                fontWeight: "bold",
                color: "var(--accent-text)",
              }}
            >
              Initiate Omnichain Journey from ETH to ...
            </s.TextTitle>
            <s.TextDescription
              style={{
                textAlign: "center",
                color: "var(--primary-text)",
              }}
            >
             Contract Address: <StyledLink target={"_blank"} href={CONFIG.SCAN_LINK}>
                {truncate(CONFIG.OMNI_CONTRACT_ADDRESS, 15)}
              </StyledLink>
            </s.TextDescription>
            <s.SpacerSmall />
              <>
                {blockchain.account === "" ||
                blockchain.gp_smartContract === null ? (
                  <s.Container ai={"center"} jc={"center"}>
                    <s.TextDescription
                      style={{
                        textAlign: "center",
                        color: "var(--accent-text)",
                      }}
                    >
                      Connect to the {CONFIG.NETWORK.NAME} network
                    </s.TextDescription>
                    <s.SpacerSmall />
                    <StyledButton
                      onClick={(e) => {
                        e.preventDefault();
                        dispatch(connect());
                        getData();
                      }}
                    >
                      CONNECT
                    </StyledButton>
                    {blockchain.errorMsg !== "" ? (
                      <>
                        <s.SpacerSmall />
                        <s.TextDescription
                          style={{
                            textAlign: "center",
                            color: "var(--accent-text)",
                          }}
                        >
                          {blockchain.errorMsg}
                        </s.TextDescription>
                      </>
                    ) : null}
                  </s.Container>
                ) : (
                  <>
                    <s.TextDescription
                      style={{
                        textAlign: "center",
                        color: "var(--accent-text)",
                      }}
                    >
                      {feedback}
                    </s.TextDescription>
                    <s.SpacerMedium />

                    {(!data.isApprovedForAll) ? (
                      <>
                        <s.TextTitle
                        style={{
                          textAlign: "center",
                          color: "var(--accent-text)",
                        }}
                      > Must run Set Approval For All to Traverse.
                      </s.TextTitle>
                      <s.SpacerMedium />
                    <s.Container ai={"center"} jc={"center"} fd={"row"}>
                      <StyledTraverseButton
                        onClick={(e) => {
                          e.preventDefault();
                          setApprovalForAll();
                          getData();
                        }}
                      > Set Approval For All
                      </StyledTraverseButton>
                    </s.Container>
                      </>
                    ) : (
                      <>
                    <s.Container ai={"center"} jc={"center"} fd={"row"}>
                      
                      <s.TextDescription
                        style={{
                          textAlign: "center",
                          color: "var(--accent-text)",
                        }}
                      >
                        Gutter Punk ID  
                      </s.TextDescription>
                    <s.SpacerXSmall /> 
                      <select onChange={updateTokenId} id="ddTokenId">
                         { data.assets.assets.map((obj) => <option value={obj.tokenID} >{obj.tokenID}</option>) }
                      </select>
                    <s.SpacerXSmall /> 
                      <s.TextDescription
                        style={{
                          textAlign: "center",
                          color: "var(--accent-text)",
                        }}
                      >
                        traverse to  
                      </s.TextDescription>
                    <s.SpacerXSmall /> 
                      <select onChange={updateChainId} id="ddChainId">
                         { CONFIG.TRAVERSAL_CHAINS.map((obj) => <option value={obj.ID} >{obj.NAME}</option>) }
                      </select>
                    </s.Container>
                    <s.SpacerMedium />
                    <s.Container ai={"center"} jc={"center"} fd={"row"}>
                      <StyledTraverseButton
                        disabled={traversingNFT ? 1 : 0}
                        onClick={(e) => {
                          e.preventDefault();
                          traverseNFT();
                          getData();
                        }}
                      >
                        {traversingNFT ? "BUSY" : "TRAVERSE"}
                      </StyledTraverseButton>
                    </s.Container>
                    </>
                    )
                    }
                  </>
                )}
              </>
            <s.SpacerMedium />
          </s.Container>
          <s.SpacerLarge />
        </ResponsiveWrapper>
        <s.SpacerMedium />
      </s.Container>
    </s.Screen>
  );
}

export default App;
