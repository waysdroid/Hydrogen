require "import"
import "mods.muk"
设置视图("layout/simple")
波纹({fh,_more},"圆主题")

初始化历史记录数据(true)

搜索内容,类型,id=...


_title.text="搜索结果"
search_result_item=获取适配器项目布局("search/search_result")

zse96_encrypt=require "model.zse96_encrypt"

search_result_pagetool=require "model.search_result":new(搜索内容,类型,id)
:initpage(simple_recy,simplesr)

task(1,function()
  a=MUKPopu({
    tittle=_title.text,
    list={

    }
  })
end)