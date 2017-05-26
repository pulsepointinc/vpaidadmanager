window.ppa.jsvpaid.ExternalScripts = function(slot, scripts) {
  this.classConstructor = arguments.callee;
  var uid = String(new Date().getTime());

  function loadScript(url, initFunc, params) {
    var js = window.document.createElement('script');
    js.src = url;
    js.addEventListener('load', function() {
      var func;
      try {
        func = eval(initFunc);
      } catch (e) {
        return;
      };
      if (typeof func === 'function' && typeof slot === 'object') {
        window.ppa.extScripts[uid].push(new func(slot, params));
      }
    });
    window.document.body.appendChild(js);
  };

  this.execute = function() {
    window.ppa.extScripts = window.ppa.extScripts || {};
    window.ppa.extScripts[uid] = new Array;
    for (var i = 0; i < scripts.length; i++) {
      loadScript(scripts[i].url, scripts[i].init_function, scripts[i].params);
    }
  };

  this.cleanup = function(){
    if (window.ppa.extScripts && window.ppa.extScripts[uid]){
      for (var i = 0; i < window.ppa.extScripts[uid].length; i++){
          if (typeof window.ppa.extScripts[uid][i].shutdown === "function"){
            window.ppa.extScripts[uid][i].shutdown();
          }
      }
    }
  }
};
