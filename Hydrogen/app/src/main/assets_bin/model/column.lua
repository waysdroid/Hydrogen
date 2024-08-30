--想法 专栏 视频项目的获取类
--author huajiqaq
--time 2023-7-09
--self:对象本身
--TODO 针对pageinfo的获取是即时性的 也就代表如果pageinfo再次多加一个内容 可能会导致内容错位 一个解决方法是使用table本地存储 不过出现几率极低


local base={}

function base:new(id,type)--类的new方法
  local child=table.clone(self)
  child.id=id
  child.type=type
  child:getinfo()
  return child
end

function base:setinfo(key,value)
  if value then
    value=value..self.id
    self[key]=value
  end
  return self
end

function base:getinfo()
  local type1=self.type
  local geturl,weburl,type2,fxurl
  switch type1
   case "文章"
    geturl="https://www.zhihu.com/api/v4/articles/"
    weburl="https://www.zhihu.com/appview/p/"
    type2="article"
    fxurl="https://zhuanlan.zhihu.com/p/"
   case "想法"
    geturl="https://www.zhihu.com/api/v4/pins/"
    weburl="https://www.zhihu.com/appview/pin/"
    type2="pin"
    fxurl="https://www.zhihu.com/appview/pin/"
   case "视频"
    geturl="https://www.zhihu.com/api/v4/zvideos/"
    weburl="https://www.zhihu.com/zvideo/"
    type2="zvideo"
    fxurl="https://www.zhihu.com/zvideo/"
   case "直播"
    weburl="https://www.zhihu.com/api/v4/drama/dramas/"
    fxurl=weburl
   case "圆桌"
    weburl="https://www.zhihu.com/roundtable/"
    type2="roundtable"
    fxurl="https://www.zhihu.com/roundtable/"
   case "专题"
    weburl="https://www.zhihu.com/special/"
    type2="special"
    fxurl="https://www.zhihu.com/special/"..result
  end

  self.urltype=type2
  self:setinfo("geturl",geturl)
  :setinfo("weburl",weburl)
  :setinfo("fxurl",fxurl)

  return self
end

function base:getData(cb,issave)
  local url=self.geturl
  if not url then
    return
  end
  zHttp.get(url,apphead,function(a,b)
    if a==200 then
      local b=luajson.decode(b)
      local type1=self.type

      if issave then
        switch type1
         case "文章","想法","视频"
          local title=b.title
          if type1=="想法" then
            title=获取想法标题(b.content[1].title)
          end
          if title=="" then
            title="一个"..type1
          end
          --修复想法标题获取异常的问题
          b.title=title
          保存历史记录(type1.."分割"..self.id,title,b.excerpt_title or b.excerpt or "")
        end
      end
      cb(b)
     else
      cb(false)
    end
  end)
end


return base