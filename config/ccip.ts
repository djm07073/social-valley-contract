interface CCIP {
  [chainid: number]: {
    router: `0x${string}`;
    link: `0x${string}`;
    socialFi: `0x${string}`;
  };
}
export const CCIP_ROUTER: CCIP = {
  56: {
    router: "0x536d7E53D0aDeB1F20E7c81fea45d02eC9dBD698",
    link: "0x404460C6A5EdE2D891e8297795264fDe62ADBB75",
    socialFi: "0x1e70972ec6c8a3fae3ac34c9f3818ec46eb3bd5d",
  }, //BNB
  8453: {
    router: "0x673aa85efd75080031d44fca061575d1da427a28",
    link: "0x88Fb150BDc53A65fe94Dea0c9BA0a6dAf8C6e196",
    socialFi: "0xCF205808Ed36593aa40a44F10c7f7C2F67d4A4d4",
  }, //BASE
  42161: {
    router: "0xE92634289A1841A979C11C2f618B33D376e4Ba85",
    link: "0xf97f4df75117a78c1A5a0DBb814Af92458539FB4",
    socialFi: "0x87da6930626fe0c7db8bc15587ec0e410937e5dc",
  }, // ARBITRUM
  420: {
    router: "0xEB52E9Ae4A9Fb37172978642d4C141ef53876f26",
    link: "0xdc2CC710e42857672E7907CF474a69B63B93089f",
    socialFi: "0x",
  }, //OPTIMISM_GOERLI
  421613: {
    router: "0x88E492127709447A5ABEFdaB8788a15B4567589E",
    link: "0xd14838A68E8AFBAdE5efb411d5871ea0011AFd28",
    socialFi: "0x",
  }, // ARBITRUM GOERLI
};
