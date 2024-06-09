(function () {

    function getsrc(doc) {
        return doc.dataset && (doc.dataset.original || doc.dataset.src) || doc.src;
    }

    function getimg(ele_src) {
        var tag = document.getElementsByTagName("img");
        var t = {};
        for (var z = 0; z < tag.length; z++) {
            if (tag[z].parentNode.className.includes("GifPlayer")) {
                t[z] = getsrc(tag[z]).replace(/(\.\w+)(\?.*)?$/, ".gif$2")
            } else {
                t[z] = getsrc(tag[z]);
            }
            if (tag[z].src == ele_src) {
                t[tag.length] = z;
            }
        };
        return t
    }

    function isZhihuPage() {
        return window.location.hostname.includes('zhihu.com');
    }

    function inject(doc) {

        if (doc.isInit) return

        if (isZhihuPage() && doc.parentNode.className.includes("GifPlayer")) {
            doc.onclick = function (e) {
                if (this.parentNode.className.includes("isPlaying")) {
                    e.stopPropagation()
                } else {
                    this.src = this.src.replace(/(\.\w+)(\?.*)?$/, ".gif$2");
                    this.dataset.original = this.src;
                    e.stopPropagation()
                    this.parentNode.className = this.parentNode.className + " isPlaying"
                    for (var i = 0; i < this.parentNode.childNodes.length; i++) {
                        if (this.parentNode.childNodes[i].tagName != "IMG") {
                            console.log(this.parentNode.childNodes[i])
                            this.parentNode.childNodes[i].style.display = "none"
                            this.parentNode.childNodes[i].style.pointerEvents = "none"
                        }
                    }
                    return
                }
            }
        }

        doc.addEventListener("click", function () {
            window.androlua.execute(JSON.stringify(getimg(this.src)));
        })

        doc.isInit = true

    };


    function init() {

        if (isZhihuPage()) {
            //优化gif显示
            var style
            style = document.createElement('style');
            style.innerHTML = '.GifPlayer img + [class*="GifPlayer"][class*="gif"]{pointer-events:none !important;display:none !important}'
            //style.innerHTML += '.GifPlayer-icon{pointer-events:none !important;display:none !important}'
            document.head.appendChild(style);
        }

        var observer = new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                if (mutation.type === 'childList') {
                    var addedNodes = mutation.addedNodes;
                    for (var i = 0; i < addedNodes.length; i++) {
                        var node = addedNodes[i];
                        if (node.tagName === 'IMG') {
                            inject(node);
                        }
                    }
                } else if (mutation.type === 'attributes') {
                    // 属性变化
                    if (mutation.target.tagName === 'IMG') {
                        inject(mutation.target);
                    }
                }
            });
        });
        var config = { childList: true, subtree: true, attributes: true, attributeFilter: ['src'] };
        observer.observe(document.body, config);
    }

    window.addEventListener("load", init)

})();