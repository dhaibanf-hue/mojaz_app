-- وظيفة لزيادة نقاط المستخدم بشكل آمن من داخل قاعدة البيانات
create or replace function increment_points(user_id uuid, amount int)
returns void as $$
begin
  -- تحديث جدول البروفايل بإضافة النقاط وتحديث وقت التعديل
  update profiles
  set points = points + amount,
      updated_at = now()
  where id = user_id;
  
  -- ملاحظة: يمكنك هنا إضافة منطق إضافي مثل تسجيل "إنجاز" إذا لزم الأمر
end;
$$ language plpgsql;

-- ملاحظة لمطور موجز:
-- بعد تشغيل هذا الكود في SQL Editor، سيتمكن التطبيق من استدعاء هذه الوظيفة 
-- عبر الأمر: client.rpc('increment_points', ...)
