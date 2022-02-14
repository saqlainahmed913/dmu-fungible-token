App = {
  web3Provider: null,
  contracts: {},
  names: new Array(),
  url: 'http://127.0.0.1:7545',
  Manager:null,
  currentAccount:null,
  init: function() {
    return App.initWeb3();
  },
  
  initWeb3: function () {
    // Is there is an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fallback to the TestRPC
      App.web3Provider = new Web3.providers.HttpProvider(App.url);
    }
    web3 = new Web3(App.web3Provider);
    ethereum.enable();
    return App.initContract();
  },
  
  initContract: function() {
      $.getJSON('DMU.json', function(data) {
    // Get the necessary contract artifact file and instantiate it with truffle-contract
    var supplyArtifact = data;
    App.contracts.supply = TruffleContract(supplyArtifact);

    // Set the provider for our contract
    App.contracts.supply.setProvider(App.web3Provider);
    
    return App.bindEvents();
  });
  },
  
  bindEvents: function() {
    $(document).on('click', '#decimals', App.handleDecimal);
  },
  
   handleDecimal : function() {
	   concole.log("The decimal value is 2");
	App.contracts.supply.deployed().then(function(instance) {
      alert(instance.decimals + "  is the decimal value ! :)");
    })
   }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
   
   
   
   
  
  