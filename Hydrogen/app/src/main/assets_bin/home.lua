require "import"
import "mods.muk"

import "android.os.Handler"
import "java.lang.Runnable"
import "com.michael.NoScrollListView"
import "com.michael.NoScrollGridView"
import "android.widget.ImageView$ScaleType"
import "com.lua.custrecycleradapter.*"
import "androidx.recyclerview.widget.*"

import "com.google.android.material.bottomnavigation.BottomNavigationView"
import "androidx.viewpager.widget.ViewPager"
import "androidx.core.widget.NestedScrollView"
import "com.michael.NoScrollListView"
import "androidx.appcompat.widget.LinearLayoutCompat"
import "com.google.android.material.appbar.*"
import "com.google.android.material.floatingactionbutton.FloatingActionButton"

import "androidx.swiperefreshlayout.widget.*"
import "com.google.android.material.tabs.TabLayout"


import "com.kn.MyLuaAdapter"
import "com.bumptech.glide.Glide"

import "com.daimajia.androidanimations.library.Techniques"
import "com.daimajia.androidanimations.library.YoYo"
import "com.getkeepsafe.taptargetview.*"


activity.setSupportActionBar(toolbar)
activity.setContentView(loadlayout("layout/home"))

初始化历史记录数据(true)


if activity.getSharedData("signdata")~=nil then
  local login_access_token="Bearer"..require "cjson".decode(activity.getSharedData("signdata")).access_token;
  access_token_head={
    ["authorization"] = login_access_token;
    ["cookie"] = 获取Cookie("https://www.zhihu.com/");
  }
 else
  --获取失败时的执行
  access_token_head={
    ["cookie"] = 获取Cookie("https://www.zhihu.com/");
  }
end

local function firsttip ()
  activity.setSharedData("禁用缓存","true")
  双按钮对话框("提示","软件默认开启「禁用缓存」和 想法功能 你可以在设置中手动设置此开关","我知道了","跳转设置",function()
    关闭对话框(an) end,function()
    关闭对话框(an) 跳转页面("settings")
  end)
end

local ccc=activity.getSharedData("第一次提示")
if ccc ==nil then
  双按钮对话框("注意","该软件仅供交流学习，严禁用于商业用途，请于下载后的24小时内卸载","登录","知道了",function()
    activity.setSharedData("第一次提示","x")
    跳转页面("login")
    关闭对话框(an)
    end,function()
    activity.setSharedData("第一次提示","x")
    关闭对话框(an)
    firsttip ()
  end)
end

local lll=activity.getSharedData("禁用缓存")
if lll==nil and ccc~=nil then
  firsttip ()
end

local qqq=activity.getSharedData("开启想法")

if ccc and lll and activity.getSharedData("开源提示")==nil then
  activity.setSharedData("开源提示","true")
  双按钮对话框("提示","本软件已开源 请问是否跳转开源页面?","我知道了","跳转开源地址",function()
    关闭对话框(an) end,function()
    关闭对话框(an) 浏览器打开("https://gitee.com/huajicloud/Hydrogen/")
  end)
end

if this.getSharedData("自动清理缓存") == nil then
  this.setSharedData("自动清理缓存","true")
end

if this.getSharedData("标题简略化") == nil then
  this.setSharedData("标题简略化","false")
end

if this.getSharedData("全屏模式") then
  this.setSharedData("全屏模式","false")
end

MDC_R=luajava.bindClass"com.jesse205.R"

array = activity.getTheme().obtainStyledAttributes(activity.getThemeResId(),{

  MDC_R.attr.colorSurface
})
colorSurfaceVariant=array.getColor(0,0)
ctl.BackgroundColor=tonumber(colorSurfaceVariant)
toolbar.BackgroundColor=tonumber(colorSurfaceVariant)

pagadp=SWKLuaPagerAdapter()

local home_layout_table=require("layout/home_layout/page_home")

m = {
  { MenuItem,
    title = "主页",
    id = "home_tab",
    enabled=true;
    icon = 图标("home");
  },
  { MenuItem,
    title = "想法",
    id = "think_tab",
    enabled=true;
    icon = 图标("bubble_chart")
  },
  { MenuItem,
    title = "热榜",
    id = "hot_tab",
    enabled=true;
    icon = 图标("fire")
  },
  { MenuItem,
    title = "关注",
    id = "following_tab",
    enabled=true;
    icon = 图标("group")
  },

}

if qqq==nil or qqq~="false" then
  activity.setSharedData("开启想法","true")
  qqq=activity.getSharedData("开启想法")
  home_list={["推荐"]=0,["想法"]=1,["热榜"]=2,["关注"]=3}
 elseif qqq=="false" then
  home_list={["推荐"]=0,["热榜"]=1,["关注"]=2}

  if this.getSharedData("starthome")=="想法" then
    this.setSharedData("starthome","推荐")
    提示("由于想法已关闭 主页为想法 为避免异常已调整主页为推荐")
  end

  table.remove(home_layout_table,2)
  table.remove(m,2)
end

for i =1,#home_layout_table do
  pagadp.add(loadlayout(home_layout_table[i]))
end



page_home.setAdapter(pagadp)
optmenu = {}

loadmenu(bnv.getMenu(), m, optmenu, 3)

ctl.setTitle("主页")

--主页布局
itemc2=获取适配器项目布局("home/home_layout")
requrl={}

function 切换页面(z)--切换主页Page函数
  if qqq~="true" and z>0 then
    page_home.setCurrentItem(z-1)
   else
    page_home.setCurrentItem(z)
  end
end
isadd=true
function 主页刷新(isclear)

  function resolve_feed(v)
    local 点赞数=tointeger(v.target.voteup_count)
    local 评论数=tointeger(v.target.comment_count)
    local 标题,问题id等;
    local 作者=v.target.author.name
    --          local 预览内容=作者.." : "..v.target.excerpt_new
    local 预览内容=作者.." : "..v.target.excerpt
    --     print(dump(v))
    if v.target.type=="pin" then
      问题id等="想法分割"..v.target.url:match("(%d+)")--由于想法的id长达18位，而cJSON无法解析这么长的数字，所以暂时用截取url结尾的数字字符串来获取id
      标题=作者.."发表了想法"
     elseif v.target.type=="answer" then
      问题id等=tointeger(v.target.question.id or 1).."分割"..tointeger(v.target.id)
      标题=v.target.question.title
     elseif v.target.type=="article" then--????????没有测到这个推荐流
      问题id等="文章分割"..tointeger(v.target.id)
      标题=v.target.title
     elseif v.target.type=="zvideo" then
      问题id等="视频分割"..v.target.id
      标题=v.target.title
     else
      --      提示("未知类型"..v.target.type or "无法获取type".." id"..v.target.id or "无法获取id")
    end
    return {点赞2=点赞数,标题2=标题,文章2=预览内容,评论2=评论数,链接2=问题id等}
  end

  function 主页推荐刷新(result)

    local url= requrl[result] or "https://api.zhihu.com/feed-root/section/"..tointeger(result).."?channelStyle=0"
    Http.get(url,access_token_head,function(code,content)
      if code==200 then
        decoded_content = require "cjson".decode(content)
        if decoded_content.paging.is_end==false then
          requrl[result]=decoded_content.paging.next
          for k,v in ipairs(decoded_content.data) do
            table.insert(list2.adapter.getData(),resolve_feed(v))
          end
          task(1,function() list2.adapter.notifyDataSetChanged()end)
        end
      end
    end)
  end

  function 随机推荐 ()
    local posturl = requrl[-1] or "https://api.zhihu.com/topstory?action=down"--"https://api.zhihu.com/feeds"
    local head = {
      ["cookie"] = 获取Cookie("https://www.zhihu.com/")
    }
    Http.get(posturl,head,function(code,content)
      if code==200 then
        decoded_content = require "cjson".decode(content)
        for k,v in ipairs(decoded_content.data) do
          table.insert(list2.adapter.getData(),resolve_feed(v))
        end
        task(1,function() list2.adapter.notifyDataSetChanged()end)
        requrl[-1] = decoded_content.paging.next
       elseif code==401 then
        提示("请登录后访问推荐，http错误码401")
        --[[      list2.Text="请先登录"
      list9.Text="请先登录"]]
        -- list2.setVisibility(8)
        -- empty2.setVisibility(0)
        -- list9.setVisibility(8)
        -- empty9.setVisibility(0)
       elseif code==403 then
        decoded_content = require "cjson".decode(content)
        if decoded_content.error and decoded_content.error.message and decoded_content.error.redirect then
          AlertDialog.Builder(this)
          .setTitle("提示")
          .setMessage(decoded_content.error.message)
          .setCancelable(false)
          .setPositiveButton("立即跳转",{onClick=function() activity.newActivity("huida",{decoded_content.error.redirect}) 提示("已跳转 成功后请自行退出") end})
          .show()
        end
       else
        提示("获取数据失败，请检查网络是否正常，http错误码"..code)
      end

    end)
  end


  if not requrl[-1] or isclear then

    local yxuan_adpqy=LuaAdapter(activity,itemc2)
    list2.adapter=yxuan_adpqy

    list2.setOnItemClickListener(AdapterView.OnItemClickListener{
      onItemClick=function(parent,v,pos,id)

        local open=activity.getSharedData("内部浏览器查看回答")
        if tostring(v.Tag.链接2.text):find("文章分割") then

          activity.newActivity("column",{tostring(v.Tag.链接2.Text):match("文章分割(.+)"),tostring(v.Tag.链接2.Text):match("分割(.+)")})

         elseif tostring(v.Tag.链接2.text):find("想法分割") then
          activity.newActivity("column",{tostring(v.Tag.链接2.Text):match("想法分割(.+)"),"想法"})

         elseif tostring(v.Tag.链接2.text):find("视频分割") then
          activity.newActivity("column",{tostring(v.Tag.链接2.Text):match("视频分割(.+)"),"视频"})

         else

          保存历史记录(v.Tag.标题2.Text,v.Tag.链接2.Text,50)

          if open=="false" then

            activity.newActivity("answer",{tostring(v.Tag.链接2.Text):match("(.+)分割"),tostring(v.Tag.链接2.Text):match("分割(.+)")})
           else
            activity.newActivity("huida",{"https://www.zhihu.com/question/"..tostring(v.Tag.链接2.Text):match("(.+)分割").."/answer/"..tostring(v.Tag.链接2.Text):match("分割(.+)")})
          end
        end
      end
    })

    list2_r.setOnScrollChangeListener{
      onScrollChange=function(view,scrollX,scrollY,oldScrollX,oldScrollY)
        if scrollY == (view.getChildAt(0).getMeasuredHeight() - view.getMeasuredHeight())
          sr.setRefreshing(true)
          主页刷新()
          System.gc()
          Handler().postDelayed(Runnable({
            run=function()
              sr.setRefreshing(false);
            end,
          }),1000)

        end
      end
    }

    --新建适配器
  end
  if choosebutton==nil then
    随机推荐()
   elseif choosebutton then
    主页推荐刷新(choosebutton)
  end
end

sr.setProgressBackgroundColorSchemeColor(转0x(backgroundc));
sr.setColorSchemeColors({转0x(primaryc)});
sr.setOnRefreshListener({
  onRefresh=function()
    主页刷新(true)
    Handler().postDelayed(Runnable({
      run=function()
        sr.setRefreshing(false);
      end,
    }),1000)

  end,
});


Http.get("https://api.zhihu.com/feed-root/sections/query/v2",access_token_head,function(code,content)
  if code==200 then
    local decoded_content = require "cjson".decode(content)
    --    提示(require "cjson".decode(content).selected_sections[1].section_name)
    for i=1, #decoded_content.selected_sections do
      --提示(tostring(i))
      if homehome~="ok" then
        local tab=HometabLayout.newTab()
        tab.setText("全站")
        tab.view.onClick=function() pcall(function()list2.adapter.clear()end) choosebutton=nil 随机推荐() end
        HometabLayout.addTab(tab)
        homehome="ok"
      end
      if HometabLayout.getTabCount()<i+1 and decoded_content.selected_sections[i].section_name~="圈子" then
        local tab=HometabLayout.newTab()
        tab.setText(decoded_content.selected_sections[i].section_name)
        tab.view.onClick=function()
          pcall(function()list2.adapter.clear()end)
          choosebutton=decoded_content.selected_sections[i].section_id
          主页推荐刷新(decoded_content.selected_sections[i].section_id)
        end
        HometabLayout.addTab(tab)
        --[[
        hometab:addTab(
        decoded_content.selected_sections[i].section_name,function() pcall(
          function()list2.adapter.clear()end
          ) choosebutton=decoded_content.selected_sections[i].section_id 主页推荐刷新(
          decoded_content.selected_sections[i].section_id
          ) end
        )
        ]]
      end
    end
   else
    HometabLayout.setVisibility(8)
  end
end)
主页刷新()

function bnv.onNavigationItemSelected(item)
  item = item.getTitle();
  activity.setTitle(item)
  if item =="主页" then item="推荐" end
  page_home.setCurrentItem(home_list[item])

  --print(itemId)
  return true;
end

fab.setVisibility(8)

fab.setImageBitmap((loadbitmap(图标("refresh"))))
fab.onClick=function() 主页刷新("refresh") end
page_home.addOnPageChangeListener(ViewPager.OnPageChangeListener {

  onPageScrolled=function( position, positionOffset, positionOffsetPixels)

  end;


  onPageSelected=function(position)
    local pos=position
    if qqq ~="true" then
      pos=pos+1
    end
    if position == 0 then
      pos=position
    end
    for i=0,bnv.getChildCount() do
      --print(bnv.getChildCount(),i)
      bnv.getMenu().getItem(i).setChecked(false)
    end
    bnv.getMenu().getItem(position).setChecked(true)
    ctl.Title=(bnv.getMenu().getItem(position).getTitle())
    --[[
    if position==0 then
      fab.setVisibility(0)
      YoYo.with(Techniques.ZoomIn).duration(200).playOn(fab)
     else
      YoYo.with(Techniques.ZoomOut).duration(200).playOn(fab)
      task(50,function()fab.setVisibility(8)end)
    end
  ]]


    if pos == 1 then
      想法刷新(true)
    end

    if pos == 2 then
      import "model.hot"
      hotdata=hot:new()
      hotdata:getPartition(function()
        热榜刷新(true)
      end)
    end

    if pos == 3 then
      关注刷新(1,nil,true)
    end

  end;


  onPageScrollStateChanged=function(state)

  end
});

function 日报刷新(isclear)

  if isclear then
    itemc3=获取适配器项目布局("home/home_daily")
    thisdata=1
    yuxun_adpqy=LuaAdapter(activity,itemc3)
    list1.Adapter=yuxun_adpqy
    news={}
    list1.setOnItemClickListener(AdapterView.OnItemClickListener{
      onItemClick=function(parent,v,pos,id)
        --    activity.newActivity("huida",{"https://daily.zhihu.com/story/"..v.Tag.导向链接3.Text})
        activity.newActivity("huida",{v.Tag.导向链接3.Text})
      end

    })

    list1.setOnScrollListener{
      onScrollStateChanged=function(view,scrollState)
        if scrollState == 0 then
          if list1.getLastVisiblePosition() == list1.getCount() - 1
            日报刷新()
            System.gc()
          end
        end
      end
    }
  end

  --  链接= 'http://www.zhihudaily.me/'
  thisdata=thisdata-1
  import "android.icu.text.SimpleDateFormat"
  cal=Calendar.getInstance();
  cal.add(Calendar.DATE,tointeger(thisdata));
  d=cal.getTime();
  sp= SimpleDateFormat("yyyyMMdd");
  ZUOTIAN=sp.format(d);
  链接 = 'https://kanzhihu.pro/api/news/'..tostring(ZUOTIAN)
  Http.get(链接,function(code,content)
    --  news[tostring(ZUOTIAN)]=content
    if thisdata==0 then
      newnews=content
     elseif thisdata==-1 then
      if content==newnews
        return
      end
    end

    for k,v in ipairs(require "cjson".decode(content).data.stories) do
      table.insert(yuxun_adpqy.getData(),{标题3=v.title,导向链接3=v.url})
      task(1,function() yuxun_adpqy.notifyDataSetChanged()end)
    end
  end)
end

_drawer.setDrawerListener(DrawerLayout.DrawerListener{
  onDrawerSlide=function(v,z)
    --侧滑滑动事件
    local k=_drawer.isDrawerOpen(3)
    local dz
    if k==false then
      dz=z*180
     else
      dz=-z*180
    end
    --与标题栏图标联动
    _menu.rotation=dz
    if z>0.5 then
      _menu.scaleX=1-z*0.08
      _menu.scaleY=1-z*0.08
     else
      _menu.scaleX=1
      _menu.scaleY=1
    end
    _menu_1.rotation=z*45
    _menu_2.scaleX=1-z/3.8
    _menu_3.rotation=-z*45
    _menu_1.scaleX=1-z/2.4
    _menu_1.setTranslationY(z*3.2)
    _menu_1.setTranslationX(z*8.)
    _menu_3.scaleX=1-z/2.4
    _menu_3.setTranslationY(-z*3.2)
    _menu_3.setTranslationX(z*8)
    _drawer.setScrimColor(0)
    _drawer.getChildAt(0).translationX=_drawer.getChildAt(1).getChildAt(0).width*z
end})

import "com.google.android.material.shape.*"

shapeAppearanceModel1 = ShapeAppearanceModel.builder()
.setTopLeftCorner(CornerFamily.ROUNDED, 0)
.setTopRightCorner(CornerFamily.ROUNDED, dp2px(24))
.setBottomRightCorner(CornerFamily.ROUNDED, dp2px(24))
.setBottomLeftCorner(CornerFamily.ROUNDED, 0)
.build()

--侧滑列表项目
drawer_item={
  {--侧滑标题 (type1)
    LinearLayout;
    Focusable=true;
    layout_width="fill";
    layout_height="wrap";
    {
      TextView;
      id="title";
      textSize="14sp";
      textColor=primaryc;
      layout_marginTop="8dp";
      layout_marginLeft="16dp";
      Typeface=字体("product");
    };
  };

  {--侧滑项目 (type2)
    RelativeLayout;
    layout_width="-1";
    layout_height="48dp";
    BackgroundColor=backgroundc;
    {
      MaterialCardView;
      layout_width="-1";
      layout_height="-1";
      StrokeColor=cardedge;
      CardBackgroundColor=backgroundc;
      layout_marginTop="1dp";
      layout_marginRight="8dp";
      StrokeWidth=0,
      ShapeAppearanceModel=shapeAppearanceModel1,
      {
        LinearLayout;
        layout_width="-1";
        layout_height="-1";
        gravity="center|left";
        ripple="圆自适应";
        {
          ImageView;
          id="iv";
          ColorFilter=textc;
          layout_marginLeft="24dp";
          layout_width="24dp";
          layout_height="24dp";
        };
        {
          TextView;
          id="tv";
          layout_marginLeft="16dp";
          textSize="14sp";
          Typeface=字体("product");
        };
      };
    };
  };

  {--侧滑项目_选中项 (type3)
    RelativeLayout;
    layout_width="-1";
    layout_height="48dp";
    BackgroundColor=backgroundc;
    {
      MaterialCardView;
      layout_width="-1";
      layout_height="-1";
      StrokeColor=cardedge;
      CardBackgroundColor=转0x(primaryc)-0xde000000;
      layout_marginTop="1dp";
      layout_marginRight="8dp";
      StrokeWidth=dp2px(1),
      ShapeAppearanceModel=shapeAppearanceModel1,
      {
        LinearLayout;
        layout_width="-1";
        layout_height="-1";
        gravity="center|left";
        ripple="圆自适应";
        {
          ImageView;
          id="iv";
          ColorFilter=primaryc;
          layout_marginLeft="24dp";
          layout_width="24dp";
          layout_height="24dp";
        };
        {
          TextView;
          id="tv";
          layout_marginLeft="16dp";
          textSize="14sp";
          textColor=primaryc;
          Typeface=字体("product");
        };
      };
    };
  };

  {--侧滑_分割线 (type4)
    LinearLayout;
    layout_width="-1";
    layout_height="-2";
    gravity="center|left";
    onClick=function()end;
    {
      TextView;
      layout_width="-1";
      layout_height="3px";
      --     background=cardedge,
      background=cardback,
      layout_marginTop="8dp";
      layout_marginBottom="8dp";
    };
  };
};


--侧滑列表适配器
adp=LuaMultiAdapter(activity,drawer_item)
adp.add{__type=4}
adp.add{__type=3,iv={src=图标("home")},tv="主页"}
adp.add{__type=2,iv={src=图标("book")},tv="收藏"}
adp.add{__type=2,iv={src=图标("work")},tv="日报"}
adp.add{__type=2,iv={src=图标("bubble_chart")},tv="想法"}
adp.add{__type=4}
adp.add{__type=2,iv={src=图标("settings")},tv="设置"}
adp.add{__type=4}
adp.add{__type=2,iv={src=图标("settings")},tv="设置"}
adp.add{__type=2,iv={src=图标("settings")},tv="测试"}
adp.add{__type=2,iv={src=图标("bug_report")},tv="Cookie"}
drawer_lv.setAdapter(adp)

--侧滑项目
ch_table={
  "分割线",
  {"主页","home",},
  {"收藏","book",},
  {"日报","work",},
  {"消息","message",},
  "分割线",
  {"一文","insert_drive_file",},
  {"本地","inbox",},
  "分割线",
  {"历史","history",},
  {"设置","settings",},
  --   {"debug","settings",},
  --  {"Cookie","bug_report",},
};



--侧滑列表高亮项目函数
function ch_light(n)
  adp.clear()
  for i,v in ipairs(ch_table) do
    if v=="分割线"then
      adp.add{__type=4}
     elseif n==v[1] then
      adp.add{__type=3,iv={src=图标(v[2])},tv=v[1]}
     else
      adp.add{__type=2,iv={src=图标(v[2])},tv=v[1]}
    end
  end
end

ch_light("主页")--设置高亮项目为“主页”
--侧滑列表点击事件
drawer_lv.setOnItemClickListener(AdapterView.OnItemClickListener{
  onItemClick=function(id,v,zero,one)
    --项目点击事件
    local s=v.Tag.tv.Text

    if s=="退出" then--判断项目并执行代码
      关闭页面()
     elseif s=="主页" then
      ch_light("主页")
      if isstart=="true" then
        a=MUKPopu({
          tittle="菜单",
          list={
            {src=图标("email"),text="反馈",onClick=function()
                跳转页面("feedback")
            end},
            {src=图标("info"),text="关于",onClick=function()
                跳转页面("about")
            end},
          }
        })
      end
      --显示主页viewpager
      控件显示(page_home)
      --显示主页底部栏
      控件显示(bottombar)
      控件隐藏(page_daily)
      控件隐藏(page_collections)
      切换页面(0)
      ctl.setTitle("主页")
     elseif s=="日报" then
      ch_light("日报")
      if isstart=="true" then
        a=MUKPopu({
          tittle="菜单",
          list={
            {src=图标("email"),text="反馈",onClick=function()
                跳转页面("feedback")
            end},
            {src=图标("info"),text="关于",onClick=function()
                跳转页面("about")
            end},
          }
        })
      end
      日报刷新(true)
      --隐藏主页viewpager
      控件隐藏(page_home)
      --隐藏主页底部栏
      控件隐藏(bottombar)
      控件隐藏(page_collections)
      控件可见(page_daily)
      ctl.setTitle("日报")
     elseif s=="收藏" then
      ch_light("收藏")
      if isstart=="true" then
        a=MUKPopu({
          tittle="菜单",
          list={
            {src=图标("search"),text="在收藏中搜索",onClick=function()
                if 状态=="未登录" then
                  提示("你可能需要登录哦")
                 else
                  InputLayout={
                    LinearLayout;
                    orientation="vertical";
                    Focusable=true,
                    FocusableInTouchMode=true,
                    {
                      EditText;
                      hint="输入";
                      layout_marginTop="5dp";
                      layout_marginLeft="10dp",
                      layout_marginRight="10dp",
                      layout_width="match_parent";
                      layout_gravity="center",
                      id="edit";
                    };
                  };

                  AlertDialog.Builder(this)
                  .setTitle("请输入")
                  .setView(loadlayout(InputLayout))
                  .setPositiveButton("确定", {onClick=function() activity.newActivity("search_result",{edit.text}) end})
                  .setNegativeButton("取消", nil)
                  .show();
                end
            end},
            {src=图标("email"),text="反馈",onClick=function()
                跳转页面("feedback")
            end},
            {src=图标("info"),text="关于",onClick=function()
                跳转页面("about")
            end},
          }
        })
      end
      --隐藏主页viewpager
      控件隐藏(page_home)
      --隐藏主页底部栏
      控件隐藏(bottombar)
      控件隐藏(page_daily)
      控件可见(page_collections)
      task(400,function()收藏刷新(true) end)
      ctl.setTitle("收藏")
      --      _title.Text="收藏"
     elseif s=="本地" then
      --activity.newActivity("local_list")
      task(300,function()activity.newActivity("local_list")end)
     elseif s=="debug" then
      --activity.newActivity("feedback")
      task(300,function()activity.newActivity("feedback")end)
     elseif s=="设置" then
      task(300,function()activity.newActivity("settings")end)
     elseif s=="一文" then
      --activity.newActivity("artical")
      task(300,function()activity.newActivity("artical")end)
     elseif s=="Cookie" then
      双按钮对话框("查看Cookie", 获取Cookie("https://www.zhihu.com/"),"复制","关闭",function()复制文本(获取Cookie("https://www.zhihu.com/"))提示("已复制到剪切板")关闭对话框(an)end,function()关闭对话框(an)end)
     elseif s=="历史" then
      --  activity.newActivity("history")
      task(300,function()activity.newActivity("history")end)
     elseif s=="消息" then

      if 状态=="未登录" then
        提示("你可能需要登录")
       else
        task(20,function()
          AlertDialog.Builder(this)
          .setTitle("请选择")
          .setSingleChoiceItems({"通知","私信"}, 0,{onClick=function(v,p)
              if p==0 then
                jumpurl="https://www.zhihu.com/notifications"
              end
              if p==1 then
                jumpurl ="https://www.zhihu.com/messages"
              end
          end})
          .setNegativeButton("确定", {onClick=function() if jumpurl==nil then jumpurl="https://www.zhihu.com/notifications" end activity.newActivity("huida",{jumpurl,true,true}) jumpurl=nil 提示("如显示不全请自行缩放") end})
          .show();
        end)
      end
     else
      Snakebar(s)

    end
    task(1,function()
      require "import"
      _drawer.closeDrawer(Gravity.LEFT)--关闭侧滑
    end)
end})




function 热榜刷新(isclear)

  if isclear then
    itemc=获取适配器项目布局("home/home_hot")

    热榜adp=MyLuaAdapter(activity,itemc)

    list3.adapter=热榜adp

    hotsr.setProgressBackgroundColorSchemeColor(转0x(backgroundc));
    hotsr.setColorSchemeColors({转0x(primaryc)});
    hotsr.setOnRefreshListener({
      onRefresh=function()
        热榜刷新()
        Handler().postDelayed(Runnable({
          run=function()
            hotsr.setRefreshing(false);
          end,
        }),1000)

      end,
    });


    list3.setOnItemClickListener(AdapterView.OnItemClickListener{
      onItemClick=function(parent,v,pos,id)

        local open=activity.getSharedData("内部浏览器查看回答")

        if tostring(v.Tag.导向链接.text):find("文章分割") then
          activity.newActivity("column",{tostring(v.Tag.导向链接.Text):match("文章分割(.+)"),tostring(v.Tag.导向链接.Text):match("分割(.+)")})

         elseif tostring(v.Tag.导向链接.text):find("想法分割") then
          activity.newActivity("column",{tostring(v.Tag.链接2.Text):match("想法分割(.+)"),"想法"})
         else
          保存历史记录(v.Tag.标题.Text,v.Tag.导向链接.Text,50)
          if open=="false" then

            activity.newActivity("question",{v.Tag.导向链接.Text,nil})
           else
            activity.newActivity("huida",{"https://www.zhihu.com/question/"..tostring(v.Tag.导向链接.Text)})
          end
        end
      end
    })

  end

  pcall(function()热榜adp.clear()end)
  Handler().postDelayed(Runnable({
    run=function()
      Http.get(hotdata:getValue(nil,true),function(code,content)
        if code==200 then--判断网站状态
          local tab=require "cjson".decode(content).data

          for i=1,#tab do
            local 标题,热度,排行,导向链接=tab[i].target.title,tab[i].detail_text,i,tointeger(tab[i].target.id)..""
            local 热榜图片=tab[i].children[1].thumbnail
            if tab[i].target.type=="article" then
              导向链接="文章分割"..tointeger(tab[i].target.id)
            end
            table.insert(热榜adp.getData(),{标题=标题,热度=热度,排行=排行,导向链接=导向链接,热图片={src=热榜图片,Visibility=#热榜图片>0 and 0 or 8}})
            Glide.get(this).clearMemory();
          end
          Glide.get(this).clearMemory();
          热榜adp.notifyDataSetChanged()
         else
          --错误时的操作
        end
      end)
    end
  }),120)
end


function 关注刷新(ppage,url,isclear)
  -- origin15.19 更改
  if isclear then
    datas9={}
    --关注布局
    follow_itemc=获取适配器项目布局("home/home_following")
    moments_nextUrl=""
    moments_isend=false

    gsr.setProgressBackgroundColorSchemeColor(转0x(backgroundc));
    gsr.setColorSchemeColors({转0x(primaryc)});
    gsr.setOnRefreshListener({
      onRefresh=function()
        关注刷新(1)
        isadd=true
        ppage=2
        Handler().postDelayed(Runnable({
          run=function()
            gsr.setRefreshing(false);
          end,
        }),1000)

      end,
    });

    list9_r.setOnScrollChangeListener{
      onScrollChange=function(view,scrollX,scrollY,oldScrollX,oldScrollY)
        if scrollY == (view.getChildAt(0).getMeasuredHeight() - view.getMeasuredHeight())
          gsr.setRefreshing(true)
          ppage=ppage+1
          关注刷新(ppage,moments_nextUrl)
          System.gc()
          Handler().postDelayed(Runnable({
            run=function()
              isadd=true
              gsr.setRefreshing(false)
            end,
          }),1000)
        end
      end
    }

    list9.setOnItemClickListener(AdapterView.OnItemClickListener{
      onItemClick=function(parent,v,pos,id)
        local open=activity.getSharedData("内部浏览器查看回答")
        if tostring(v.Tag.follow_id.text):find("文章分割") then
          activity.newActivity("column",{tostring(v.Tag.follow_id.Text):match("文章分割(.+)"),tostring(v.Tag.follow_id.Text):match("分割(.+)")})
         elseif tostring(v.Tag.follow_id.text):find("想法分割") then
          activity.newActivity("column",{tostring(v.Tag.follow_id.Text):match("想法分割(.+)"),tostring(v.Tag.follow_id.Text):match("分割(.+)"),"想法"})
         elseif tostring(v.Tag.follow_id.text):find("问题分割") then
          activity.newActivity("question",{tostring(v.Tag.follow_id.Text):match("问题分割(.+)"),true})
         else
          保存历史记录(v.Tag.follow_title.Text,v.Tag.follow_id.Text,50)

          if open=="false" then
            activity.newActivity("answer",{tostring(v.Tag.follow_id.Text):match("(.+)分割"),tostring(v.Tag.follow_id.Text):match("分割(.+)")})
           else
            activity.newActivity("huida",{"https://www.zhihu.com/question/"..tostring(v.Tag.follow_id.Text):match("(.+)分割").."/answer/"..tostring(v.Tag.follow_id.Text):match("分割(.+)")})
          end
        end
      end
    })
  end

  local posturl = url or "https://www.zhihu.com/api/v3/moments?limit=10"
  local head = {
    ["cookie"] = 获取Cookie("https://www.zhihu.com/")
  }

  if ppage<2 then
    local qqadpqy=LuaAdapter(activity,datas9,follow_itemc)
    list9.Adapter=qqadpqy
  end

  if 状态=="未登录" then
    提示("请登录后使用关注功能")
   else
    提示("加载中")
    local json=require "cjson"
    Http.get(posturl,head,function(code,content)
      if code==200 then
        local data=json.decode(content)
        moments_isend=data.paging.is_end
        moments_nextUrl=data.paging.next
        for k,v in ipairs(data.data) do
          if v.type=="feed_group"
            for d,e in ipairs(v.list) do
              local 关注作者头像=e.actors[1].avatar_url
              local 点赞数=tointeger(e.target.voteup_count)
              local 评论数=tointeger(e.target.comment_count)
              local 标题=e.target.title or e.target.question.title
              local 关注名字=e.action_text
              local 时间=时间戳(e.created_time)
              local 预览内容=e.target.excerpt
              if e.target.type=="answer" then
                问题id等=tointeger(e.target.question.id or 1).."分割"..tointeger(e.target.id)
                标题=e.target.question.title
               elseif e.target.type=="question" then
                问题id等="问题分割"..tointeger(e.target.id)
                标题=e.target.title
               elseif e.target.type=="article"
                问题id等="文章分割"..tointeger(e.target.id)
                标题=e.target.title
               elseif e.target.type=="pin"
                问题id等="想法分割"..tointeger(e.target.id)
                标题=e.target.title
              end
              list9.Adapter.add{follow_voteup=点赞数,follow_title=标题,follow_art=预览内容,follow_comment=评论数,follow_id=问题id等,follow_name=关注名字,follow_time=时间,follow_image=关注作者头像}

            end
           elseif v.type=="feed" then
            local 关注作者头像=v.actors[1].avatar_url
            local 点赞数=tointeger(v.target.voteup_count)
            local 评论数=tointeger(v.target.comment_count)
            local 标题=v.target.title
            local 关注名字=v.action_text
            local 时间=时间戳(v.created_time)
            local 预览内容=v.target.excerpt
            if v.target.type=="answer" then
              问题id等=tointeger(v.target.question.id or 1).."分割"..tointeger(v.target.id)
              标题=v.target.question.title
             elseif v.target.type=="question" then
              问题id等="问题分割"..tointeger(v.target.id)
              标题=v.target.title
             elseif v.target.type=="article"
              问题id等="文章分割"..tointeger(v.target.id)
              标题=v.target.title
             elseif v.target.type=="pin"
              问题id等="想法分割"..tointeger(v.target.id)
              标题=v.target.title
            end
            list9.Adapter.add{follow_voteup=点赞数,follow_title=标题,follow_art=预览内容,follow_comment=评论数,follow_id=问题id等,follow_name=关注名字,follow_time=时间,follow_image=关注作者头像}
          end
        end
       elseif require "cjson".decode(content).error.message and code==401 then
        authorerror=AlertDialog.Builder(this)
        .setTitle("提示")
        .setMessage("账号存在风险 请更改密码 由于风险问题 不更改密码会无法使用该功能")
        .setCancelable(false)
        .setPositiveButton("立即更改密码",nil)
        .show()
        authorerror.create()
        authorerror.getButton(authorerror.BUTTON_POSITIVE).onClick=function()
          activity.newActivity("huida",{"https://www.zhihu.com/account/password_reset?utm_id=0"})
        end
      end

    end)
  end
end

function 想法刷新(isclear)
  if isclear==true then

    itemcc=获取适配器项目布局("home/home_thinker")
    mytab={}

    adapter=LuaCustRecyclerAdapter(AdapterCreator({

      getItemCount=function()
        return #mytab
      end,

      getItemViewType=function(position)
        return 0
      end,

      onCreateViewHolder=function(parent,viewType)
        local views={}
        holder=LuaCustRecyclerHolder(loadlayout(itemcc,views))
        holder.view.setTag(views)
        return holder
      end,

      onBindViewHolder=function(holder,position)
        view=holder.view.getTag()

        url=mytab[position+1].url
        layoutParams=view.img.getLayoutParams()
        import "android.util.DisplayMetrics"
        dm=DisplayMetrics()
        activity.getWindowManager().getDefaultDisplay().getMetrics(dm);
        hj=loadbitmap(url)
        wtt=hj.getWidth()
        kkk=dm.widthPixels-80
        ooo=kkk/2
        koo=ooo/wtt
        layoutParams.width=ooo
        layoutParams.height=hj.getHeight()*koo


        view.img.setImageBitmap(hj)
        view.img.setLayoutParams(layoutParams)
        view.tv.Text=StringHelper.Sub(mytab[position+1].title,1,20).."....."


        --子项目点击事件
        view.it.onClick=function(v)
          activity.newActivity("column",{mytab[position+1].tzurl,"想法"})
          return true
        end

      end,
    }))

    thinksr.setProgressBackgroundColorSchemeColor(转0x(backgroundc));
    thinksr.setColorSchemeColors({转0x(primaryc)});
    thinksr.setOnRefreshListener({
      onRefresh=function()
        想法刷新(true)
        Handler().postDelayed(Runnable({
          run=function()
            thinksr.setRefreshing(false);
          end,
        }),1000)

      end,
    });


    recy_r.setOnScrollChangeListener{
      onScrollChange=function(view,scrollX,scrollY,oldScrollX,oldScrollY)
        if scrollY == (view.getChildAt(0).getMeasuredHeight() - view.getMeasuredHeight())
          thinksr.setRefreshing(true)
          想法刷新()
          System.gc()
          Handler().postDelayed(Runnable({
            run=function()
              thinksr.setRefreshing(false);
            end,
          }),1000)

        end
      end
    }

    mytab={}
    recy.setAdapter(adapter)
    recy.setLayoutManager(StaggeredGridLayoutManager(2,StaggeredGridLayoutManager.VERTICAL))
    thisurl=nil
  end
  local geturl=thisurl or "https://api.zhihu.com/prague/feed?offset=0&limit=10"
  Http.get(geturl,head,function(code,content)
    if code==200 then--判断网站状态
      thisurl=require "cjson".decode(content).paging.next
      for i,v in ipairs(require "cjson".decode(content).data) do
        local url=v.target.images[1].url
        local title=v.target.excerpt
        local tzurl=v.target.url:match("pin/(.-)?")
        table.insert(mytab,{url=url,title=title,tzurl=tzurl})
        adapter.notifyDataSetChanged()
      end
     else
      --错误时的操作
    end
  end)

end

function 收藏刷新(isclear)

  if isclear then

    CollectiontabLayout.setupWithViewPager(page)

    local CollectionTable={"我的","关注"}

    if CollectiontabLayout.getTabCount()==0 then
      for i=1, #CollectionTable do
        local tab=CollectiontabLayout.newTab()
        local pagenum=i-1
        tab.view.onClick=function() changepage(pagenum) end
        CollectiontabLayout.addTab(tab)
      end
    end

    --setupWithViewPager设置的必须手动设置text
    for i=1, #CollectionTable do
      local itemnum=i-1
      CollectiontabLayout.getTabAt(itemnum).setText(CollectionTable[i]);
    end

    function changepage(z)
      page.setCurrentItem(z,false)
    end

    datas4={}

    page.addOnPageChangeListener(ViewPager.OnPageChangeListener {
      onPageScrolled=function(a,b,c)
      end,
      onPageSelected=function(v)
      end
    })

    itemc4=获取适配器项目布局("home/home_collections")
    list4.setOnItemClickListener(AdapterView.OnItemClickListener{
      onItemClick=function(parent,v,pos,id)
        activity.newActivity("collections",{v.Tag.collections_id.Text,v.Tag.collections_title.Text})
      end
    })
    itemc8=获取适配器项目布局("home/home_shared_collections")
    list8.setOnItemClickListener(AdapterView.OnItemClickListener{
      onItemClick=function(parent,v,pos,id)
        activity.newActivity("collections",{v.Tag.mc_id.Text,v.Tag.mc_title.Text})
      end
    })
  end

  xpcall(function()
    local yuxun_ay=LuaAdapter(activity,datas4,itemc4)

    list4.Adapter=yuxun_ay
    list4.adapter.add{
      collections_title={
        text="本地收藏",
      },
      collections_art={
        text="你猜有几个内容？",
      },
      is_lock=图标("https"),

      collections_item={
        text="0",
      },
      collections_follower={
        text="0",
      },
      collections_id={
        text="local"
      },

    }

    local yuxuuun_ay=MyLuaAdapter(activity,datas8,itemc8)
    list8.Adapter=yuxuuun_ay

    local collections_url= "https://api.zhihu.com/people/"..activity.getSharedData("idx").."/collections_v2?offset=0&limit=20"

    local head = {
      ["cookie"] = 获取Cookie("https://www.zhihu.com/")
    }


    Http.get(collections_url,head,function(code,content)
      if code==200 then
        for k,v in ipairs(require "cjson".decode(content).data) do
          list4.adapter.add{
            collections_title={
              text=v.title,
            },
            is_lock=v.is_public==false and 图标("https") or nil,

            collections_art={
              text=""..tointeger(v.item_count).."个内容"
            },
            collections_item={
              text=math.floor(v.comment_count)..""
            },
            collections_follower={
              text=tointeger(v.follower_count)..""
            },
            collections_id={
              text="https://api.zhihu.com/collections/"..tointeger(v.id).."/answers?offset=0"

            },
          }
        end

       else
        提示("获取收藏列表失败")
      end
    end)

    local mc_url= "https://api.zhihu.com/people/"..activity.getSharedData("idx").."/following_collections?offset=0"
    head = {
      ["cookie"] = 获取Cookie("https://www.zhihu.com/")
    }

    Http.get(mc_url,head,function(c,ct)
      if c==200 then

        for k,v in ipairs(require "cjson".decode(ct).data) do

          list8.adapter.add{
            mc_image=v.creator.avatar_url,
            mc_name={
              text="由 "..v.creator.name.." 创建"
            },
            mc_title={
              text=v.title
            },
            mc_follower={
              text=math.floor(v.follower_count).."人关注"
            },
            mc_id={
              text="https://api.zhihu.com/collections/"..tointeger(v.id).."/answers?offset=0",
            },
            background={foreground=Ripple(nil,转0x(ripplec),"方")},
          }
        end

       else
        提示("获取收藏列表失败")
      end
    end)
    end,function()
    提示("你可能需要登录哦")
  end)
end

--设置波纹（部分机型不显示，因为不支持setColor）（19 6-6发现及修复因为不支持setColor而导致的报错问题)
波纹({_menu,_more,_search,_ask,page1,page2,page3,page5,page4,pagetest},"圆主题")
波纹({open_source},"方主题")
波纹({侧滑头},"方自适应")
波纹({注销},"圆自适应")

--获取首页启动什么
local starthome=this.getSharedData("starthome")

--没有就设置主页为推荐
if not starthome then
  this.setSharedData("starthome","推荐")
  starthome=this.getSharedData("starthome")
end

--从home_list取出启动页
page_home.setCurrentItem(home_list[starthome],false)

function getuserinfo()

  local myurl= 'https://www.zhihu.com/api/v4/me'
  head = {
    ["cookie"] = 获取Cookie("https://www.zhihu.com/")
  }
  Http.get(myurl,head,function(code,content)

    if code==200 then--判断网站状态
      local data=require "cjson".decode(content)
      local 名字=data.name
      local 头像=data.avatar_url
      local 签名=data.headline
      local uid=data.id--用tointeger不行数值太大了会
      activity.setSharedData("idx",uid)
      ---      activity.setSharedData("name",名字)
      头像id.setImageBitmap(loadbitmap(头像))
      名字id.Text=名字
      if #签名:gsub(" ","")<1 then
        签名id.Text="你还没有签名呢"
       else
        签名id.Text=签名
      end
      侧滑头.onClick=function()
        activity.newActivity("people",{uid})
      end
      sign_out.setVisibility(View.VISIBLE)
     elseif code==401 then
      状态="未登录"
    end
  end)

end

getuserinfo()

function onActivityResult(a,b,c)
  if b==100 then
    getuserinfo()
    主页刷新()
    关注刷新(1)
   elseif b==1200 then --夜间模式开启
    设置主题()
    --    activity.newActivity("home",android.R.anim.fade_in,android.R.anim.fade_out)
    --    activity.finish()
   elseif b==200 then
    activity.finish()
   elseif b==1500 then
    初始化历史记录数据(true)
   elseif b==1600 then
    收藏刷新()
  end
end


local opentab={}
function check()
  if activity.getSharedData("自动打开剪贴板上的知乎链接")~="true" then return end
  import "android.content.*"
  --导入包
  local url=activity.getSystemService(Context.CLIPBOARD_SERVICE).getText()

  url=tostring(url)

  if opentab[url]~=true then
    if url:find("zhihu.com") and 检查链接(url,true) then
      双按钮对话框("提示","检测到剪贴板里含有知乎链接，是否打开？","打开","",function()关闭对话框(an)
        opentab[url]=true
        检查链接(url)
      end)
    end
  end
end

function onResume()
  activity.getDecorView().post{run=function()check()end}
  if (oldTheme~=ThemeUtil.getAppTheme())
    or (oldDarkActionBar~=getSharedData("theme_darkactionbar"))
    then
    activity.recreate()
    return
  end
end



if not(this.getSharedData("内部浏览器查看回答")) then
  activity.setSharedData("内部浏览器查看回答","false")
end

appinfo=this.getPackageManager().getApplicationInfo(this.getPackageName(),(0))
--versionCode=tointeger(appinfo.versionCode)

local update_api= "https://mydata.huajicloud.ml/hydrogen.html"

Http.get(update_api,function(code,content)
  if code==200 then
    updateversioncode=tonumber(content:match("updateversioncode%=(.+),updateversioncode"))
    isstart=content:match("start%=(.+),start")
    this.setSharedData("解析zes开关",isstart)
    if updateversioncode > versionCode and activity.getSharedData("version")~=updateversioncode then
      updateversionname=content:match("updateversionname%=(.+),updateversionname")
      updateinfo=content:match("updateinfo%=(.+),updateinfo")
      updateurl=tostring(content:match("updateurl%=(.+),updateurl"))
      myupdatedialog=AlertDialog.Builder(this)
      .setTitle("检测到最新版本")
      .setMessage("最新版本："..updateversionname.."("..updateversioncode..")\n"..updateinfo)
      .setCancelable(false)
      .setPositiveButton("立即更新",nil)
      .setNeutralButton("暂不更新",{onClick=function() activity.setSharedData("version",updateversioncode) end})
      .show()
      myupdatedialog.create()
      myupdatedialog.getButton(myupdatedialog.BUTTON_POSITIVE).onClick=function()
        下载文件对话框("下载安装包中",updateurl,"Hydrogen.apk",false)
      end
    end
   else
    提示("检查更新失败，请检查网络连接后再试")
  end
end)

if activity.getSharedData("自动清理缓存")=="true" then
  import "androidx.core.content.ContextCompat"
  task(function(dar)
    require "import"
    import "java.io.File"
    local tmp={[1]=0}

    local function getDirSize(tab,path)
      if File(path).exists() then
        local a=luajava.astable(File(path).listFiles() or {})

        for k,v in pairs(a) do
          if v.isDirectory() then
            getDirSize(tab,tostring(v))
           else

            tab[1]=tab[1]+v.length()
          end
        end
      end
    end
    dar=tostring(ContextCompat.getDataDir(activity)).."/cache"

    local a1,a2=File("/data/data/"..activity.getPackageName().."/database/webview.db"),File("/data/data/"..activity.getPackageName().."/database/webviewCache.db")
    pcall(function()
      tmp[1]=tmp[1]+(a1.length() or 0)+(a2.length() or 0)
      a1.delete()
      a2.delete()
    end)
    LuaUtil.rmDir(File(dar))

    return tmp[1]
    end,APP_CACHEDIR,function(m)

    提示("清理成功,共清理 "..tokb(m))
  end)
end

a=MUKPopu({
  tittle="菜单",
  list={
    {src=图标("email"),text="反馈",onClick=function()
        跳转页面("feedback")
    end},
    {src=图标("info"),text="关于",onClick=function()
        跳转页面("about")
    end},
  }
})

lastclick = os.time() - 2
function onKeyDown(code,event)
  local now = os.time()
  if string.find(tostring(event),"KEYCODE_BACK") ~= nil then
    --监听返回键
    if a.pop.isShowing() then
      --如果菜单显示，关闭菜单并阻止返回键
      a.pop.dismiss()
      return true
    end
    if _drawer.isDrawerOpen(Gravity.LEFT) then
      --如果左侧侧滑显示，关闭左侧侧滑并阻止返回键
      _drawer.closeDrawer(Gravity.LEFT)
      return true
    end
    if now - lastclick > 2 then
      --双击退出
      Snakebar("再按一次退出")
      lastclick = now
      return true
    end
  end
end

data=...
function onCreate()
  if data then
    local intent=tostring(data.getData())
    检查意图(intent)
  end
end


  if 全局主题值=="Day" then
    bwz=0x3f000000
   else
    bwz=0x3fffffff
  end

  local gd2 = GradientDrawable()
  gd2.setColor(转0x(backgroundc))--填充
  local radius=dp2px(16)
  gd2.setCornerRadii({radius,radius,radius,radius,0,0,0,0})--圆角
  gd2.setShape(0)--形状，0矩形，1圆形，2线，3环形
  local dann={
    LinearLayout;
    layout_width="-1";
    layout_height="-1";
    {
      LinearLayout;
      orientation="vertical";
      layout_width="-1";
      layout_height="-2";
      Elevation="4dp";
      BackgroundDrawable=gd2;
      id="ztbj";
      {
        CardView;
        layout_gravity="center",
        --background=cardedge,
        CardBackgroundColor=cardedge;
        radius="3dp",
        Elevation="0dp";
        layout_height="6dp",
        layout_width="56dp",
        layout_marginTop="12dp";
      };
      {
        TextView;
        layout_width="-1";
        layout_height="-2";
        textSize="20sp";
        layout_marginTop="24dp";
        layout_marginLeft="24dp";
        layout_marginRight="24dp";
        Text=bt;
        Typeface=字体("product-Bold");
        textColor=primaryc;
      };
      {
        ScrollView;
        layout_width="-1";
        layout_height="-1";
        {
          TextView;
          layout_width="-1";
          layout_height="-2";
          textSize="14sp";
          layout_marginTop="8dp";
          layout_marginLeft="24dp";
          layout_marginRight="24dp";
          layout_marginBottom="8dp";
          Typeface=字体("product");
          Text=nr;
          textColor=textc;
          id="sandhk_wb";
        };
      };
      {
        LinearLayout;
        orientation="horizontal";
        layout_width="-1";
        layout_height="-2";
        gravity="right|center";
        {
          CardView;
          layout_width="-2";
          layout_height="-2";
          radius="2dp";
          --background="#00000000";
          CardBackgroundColor="#00000000";
          layout_marginTop="8dp";
          layout_marginLeft="8dp";
          layout_marginBottom="24dp";
          Elevation="0";
          onClick=qxnr;
          {
            TextView;
            layout_width="-1";
            layout_height="-2";
            textSize="16sp";
            Typeface=字体("product-Bold");
            paddingRight="16dp";
            paddingLeft="16dp";
            paddingTop="8dp";
            paddingBottom="8dp";
            Text=qx;
            textColor=stextc;
            BackgroundDrawable=activity.Resources.getDrawable(ripples).setColor(ColorStateList(int[0].class{int{}},int{bwz}));
          };
        };
        {
          CardView;
          layout_width="-2";
          layout_height="-2";
          radius="4dp";
          --background=primaryc;
          CardBackgroundColor=primaryc;
          layout_marginTop="8dp";
          layout_marginLeft="8dp";
          layout_marginRight="24dp";
          layout_marginBottom="24dp";
          Elevation="1dp";
          onClick=qdnr;
          {
            TextView;
            layout_width="-1";
            layout_height="-2";
            textSize="16sp";
            paddingRight="16dp";
            paddingLeft="16dp";
            Typeface=字体("product-Bold");
            paddingTop="8dp";
            paddingBottom="8dp";
            Text=qd;
            textColor=backgroundc;
            BackgroundDrawable=activity.Resources.getDrawable(ripples).setColor(ColorStateList(int[0].class{int{}},int{bwz}));
          };
        };
      };
    };
  };

  双按钮对话框("提示","软件默认开启「禁用缓存」和 想法功能 你可以在设置中手动设置此开关","我知道了","跳转设置",function()
    关闭对话框(an) end,function()
    关闭对话框(an) 跳转页面("settings")
  end)
  
import "com.baidu.mobstat.StatService"
StatService
.setAppKey("c5aac7351d")
.start(this)