package com.hydrogen.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.widget.*;
import com.androlua.LuaContext;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.luajava.*;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class MyLuaAdapter extends BaseAdapter implements Filterable {

    private final LuaTable<Integer, LuaTable<String, Object>> mBaseData;
    private final LuaState L;
    private final LuaContext mContext;


    private final LuaTable mLayout;
    private LuaTable<Integer, LuaTable<String, Object>> mData;
    private LuaTable<String, Object> mTheme;

    private CharSequence mPrefix;

    private final LuaFunction<View> loadlayout;

    private final LuaFunction insert;

    private final LuaFunction remove;

    private LuaFunction<Animation> mAnimationUtil;

    private final HashMap<View, Animation> mAnimCache = new HashMap<>();

    private final HashMap<View, Boolean> mStyleCache = new HashMap<>();

    private boolean mNotifyOnChange = true;

    private boolean updateing;

    @SuppressLint("HandlerLeak")

	private final Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            if (msg.what == 0) {
                notifyDataSetChanged();
            } else {
                try {
                    LuaTable<Integer, LuaTable<String, Object>> newValues = new LuaTable<>(mData.getLuaState());
                    mLuaFilter.call(mBaseData, newValues, mPrefix);
                    mData = newValues;
                    notifyDataSetChanged();
                } catch (Exception ignored) {
                }
            }
        }

    };


    private ArrayFilter mFilter;
    private LuaFunction mLuaFilter;

    public MyLuaAdapter(LuaContext context, LuaTable layout) {
        this(context, null, layout);
    }

    public MyLuaAdapter(LuaContext context, LuaTable<Integer, LuaTable<String, Object>> data, LuaTable layout) {


        mContext = context;
        mLayout = layout;


        L = context.getLuaState();
        if (data == null)
            data = new LuaTable<>(L);
        mData = data;
        mBaseData = mData;
        loadlayout = (LuaFunction<View>) L.getLuaObject("loadlayout").getFunction();
        insert = L.getLuaObject("table").getField("insert").getFunction();
        remove = L.getLuaObject("table").getField("remove").getFunction();
        L.newTable();
        loadlayout.call(mLayout, L.getLuaObject(-1), AbsListView.class);
        L.pop(1);

    }

    public void setAnimation(LuaFunction<Animation> animation) {
        setAnimationUtil(animation);
    }

    public void setAnimationUtil(LuaFunction<Animation> animation) {
        mAnimCache.clear();
        mAnimationUtil = animation;
    }

    @Override
    public int getCount() {
        // TODO: Implement this method
        return mData.length();
    }

    @Override
    public Object getItem(int position) {
        // TODO: Implement this method
        return mData.get(position + 1);
    }

    @Override
    public long getItemId(int position) {
        // TODO: Implement this method
        return position + 1;
    }

    public LuaTable<Integer, LuaTable<String, Object>> getData() {
        return mData;
    }

    public void add(LuaTable<String, Object> item) throws Exception {
        insert.call(mBaseData, item);
        if (mNotifyOnChange) notifyDataSetChanged();
    }

    public void addAll(LuaTable<Integer, LuaTable<String, Object>> items) {
        int len = items.length();
        for (int i = 1; i <= len; i++)
            insert.call(mBaseData, items.get(i));
        if (mNotifyOnChange) notifyDataSetChanged();
    }

    public void insert(int position, LuaTable<String, Object> item) {
        insert.call(mBaseData, position + 1, item);
        if (mNotifyOnChange) notifyDataSetChanged();
    }

    public void remove(int position) {
        remove.call(mBaseData, position + 1);
        if (mNotifyOnChange) notifyDataSetChanged();
    }

    public void clear() {
        mBaseData.clear();
        if (mNotifyOnChange) notifyDataSetChanged();
    }

    public void setNotifyOnChange(boolean notifyOnChange) {
        mNotifyOnChange = notifyOnChange;
        if (mNotifyOnChange) notifyDataSetChanged();
    }

    @Override
    public void notifyDataSetChanged() {
        // TODO: Implement this method
        super.notifyDataSetChanged();
        if (!updateing) {
            updateing = true;
            new Handler().postDelayed(() -> {
                // TODO: Implement this method
                updateing = false;
            }, 500);
        }
    }

    @Override
    public View getDropDownView(int position, View convertView, ViewGroup parent) {
        // TODO: Implement this method
        return getView(position, convertView, parent);
    }

    public void setStyle(LuaTable<String, Object> theme) {
        mStyleCache.clear();
        mTheme = theme;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        // TODO: Implement this method
        View view = null;
        LuaObject holder = null;
        if (convertView == null) {
            try {
                L.newTable();
                holder = L.getLuaObject(-1);
                L.pop(1);
                view = loadlayout.call(mLayout, holder, AbsListView.class);
                view.setTag(holder);
            } catch (Exception ignored) {
            }
        } else {
            view = convertView;
            holder = (LuaObject) view.getTag();
        }

        LuaTable<String, Object> hm = mData.get(position + 1);

        if (hm == null) {
            Log.i("lua", position + " is null");
            return view;
        }

        boolean bool = mStyleCache.get(view) == null;
        if (bool)
            mStyleCache.put(view, true);

        Set<Map.Entry<String, Object>> sets = hm.entrySet();
        for (Map.Entry<String, Object> entry : sets) {
            try {
                String key = entry.getKey();
                Object value = entry.getValue();
                LuaObject obj = null;
                if (holder != null) {
                    obj = holder.getField(key);
                }
                if (obj != null && obj.isJavaObject()) {
                    if (mTheme != null && bool) {
                        setHelper((View) obj.getObject(), mTheme.get(key));
                    }
                    setHelper((View) obj.getObject(), value);
                }
            } catch (Exception e) {
                Log.i("lua", e.getMessage());
            }
        }

        if (updateing) {
            return view;
        }

        if (mAnimationUtil != null && convertView != null) {
            Animation anim = mAnimCache.get(convertView);
            if (anim == null) {
                try {
                    anim = mAnimationUtil.call();
                    mAnimCache.put(convertView, anim);
                } catch (Exception e) {
                    mContext.sendError("setAnimation", e);
                }
            }
            if (anim != null) {
                view.clearAnimation();
                view.startAnimation(anim);
            }
        }
        return view;
    }

    private void setFields(View view, LuaTable<String, Object> fields) throws LuaException {
        Set<Map.Entry<String, Object>> sets = fields.entrySet();
        for (Map.Entry<String, Object> entry2 : sets) {
            String key2 = entry2.getKey();
            Object value2 = entry2.getValue();
            if (key2.equalsIgnoreCase("src"))
                setHelper(view, value2);
            else
                javaSetter(view, key2, value2);

        }
    }

    private void setHelper(View view, Object value) {
        try {
            if (value instanceof LuaTable) {
                setFields(view, (LuaTable<String, Object>) value);
            } else if (view instanceof TextView) {
                if (value instanceof CharSequence)
                    ((TextView) view).setText((CharSequence) value);
                else
                    ((TextView) view).setText(value.toString());
            } else if (view instanceof ImageView) {
                if (value instanceof Bitmap)
                    ((ImageView) view).setImageBitmap((Bitmap) value);
                else if (value instanceof String)
					Glide.with((Context)mContext)
					.load((String)value)
			        .skipMemoryCache(false)
				    .diskCacheStrategy(DiskCacheStrategy.NONE)
					.into((ImageView)view);
                else if (value instanceof Drawable)
                    ((ImageView) view).setImageDrawable((Drawable) value);
                else if (value instanceof Number)
                    ((ImageView) view).setImageResource(((Number) value).intValue());
            }
        } catch (Exception e) {
            mContext.sendError("setHelper", e);
        }
    }

    private void javaSetter(Object obj, String methodName, Object value) throws LuaException {

        if (methodName.length() > 2 && methodName.startsWith("on") && value instanceof LuaFunction) {
            javaSetListener(obj, methodName, value);
            return;
        }

        javaSetMethod(obj, methodName, value);
    }

    private void javaSetListener(Object obj, String methodName, Object value) throws LuaException {
        String name = "setOn" + methodName.substring(2) + "Listener";
        ArrayList<Method> methods = LuaJavaAPI.getMethod(obj.getClass(), name, false);
        for (Method m : methods) {

            Class<?>[] tp = m.getParameterTypes();
            if (tp.length == 1 && tp[0].isInterface()) {
                L.newTable();
                L.pushObjectValue(value);
                L.setField(-2, methodName);
                try {
                    Object listener = L.getLuaObject(-1).createProxy(tp[0]);
                    m.invoke(obj, listener);
                    return;
                } catch (Exception e) {
                    throw new LuaException(e);
                }
            }
        }
    }

    private void javaSetMethod(Object obj, String methodName, Object value) throws LuaException {
        if (Character.isLowerCase(methodName.charAt(0))) {
            methodName = Character.toUpperCase(methodName.charAt(0)) + methodName.substring(1);
        }
        String name = "set" + methodName;
        Class<?> type = value.getClass();
        StringBuilder buf = new StringBuilder();


        ArrayList<Method> methods = LuaJavaAPI.getMethod(obj.getClass(), name, false);

        for (Method m : methods) {
            Class<?>[] tp = m.getParameterTypes();
            if (tp.length != 1)
                continue;

            if (tp[0].isPrimitive()) {
                try {
                    if (value instanceof Double || value instanceof Float) {
                        m.invoke(obj, LuaState.convertLuaNumber(((Number) value).doubleValue(), tp[0]));
                    } else if (value instanceof Long || value instanceof Integer) {
                        m.invoke(obj, LuaState.convertLuaNumber(((Number) value).longValue(), tp[0]));
                    } else if (value instanceof Boolean) {
                        m.invoke(obj, value);
                    } else {
                        continue;
                    }
                    return;
                } catch (Exception e) {
                    buf.append(e.getMessage());
                    buf.append("\n");
                    continue;
                }

            }

            if (!tp[0].isAssignableFrom(type))
                continue;

            try {
                m.invoke(obj, value);
                return;
            } catch (Exception e) {
                buf.append(e.getMessage());
                buf.append("\n");
            }
        }
        if (buf.length() > 0)
            throw new LuaException("Invalid setter " + methodName + ". Invalid Parameters.\n" + buf + type);
        else
            throw new LuaException("Invalid setter " + methodName + " is not a method.\n");

    }


    /**
     * {@inheritDoc}
     */
    @Override
    public Filter getFilter() {
        if (mFilter == null) {
            mFilter = new ArrayFilter();
        }
        return mFilter;
    }

    public void filter(CharSequence constraint) {
        getFilter().filter(constraint);
    }

    public void setFilter(LuaFunction filter) {
        mLuaFilter = filter;
    }

    /**
     * <p>An array filter constrains the content of the array adapter with
     * a prefix. Each item that does not start with the supplied prefix
     * is removed from the list.</p>
     */
    private class ArrayFilter extends Filter {

        @Override
        protected FilterResults performFiltering(CharSequence prefix) {
            FilterResults results = new FilterResults();
            mPrefix = prefix;
            if (mData == null)
                return results;
            if (mLuaFilter != null) {
                mHandler.sendEmptyMessage(1);
                return null;
            }

            results.values = mData;
            results.count = mData.size();
            return results;
        }

        @Override
        protected void publishResults(CharSequence constraint, FilterResults results) {
            /*noinspection unchecked
			 mData = (LuaTable<Integer, LuaTable<String, Object>>) results.values;
			 if (results.count > 0) {
			 notifyDataSetChanged();
			 } else {
			 notifyDataSetInvalidated();
			 }*/
        }
    }

}
