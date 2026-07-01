
/* =========================================================
   Visitas por semana, mes y anio, por parque
   ========================================================= */

exec reportes.sp_visitas
exec reportes.sp_visitas_xml

exec reportes.sp_visitas_filt null, null, "MES", null;
exec reportes.sp_visitas_filt null, null, "MES", 1;
exec reportes.sp_visitas_filt "20260401", "20260801", "MES", 1;

exec reportes.sp_visitas_xml_filt null, null, "MES", null;
exec reportes.sp_visitas_xml_filt null, null, "MES", 1;
exec reportes.sp_visitas_xml_filt "20260401", "20260801", "MES", 1;

exec reportes.sp_visitas_malosdias 1, null;

/* =========================================================
   Ingresos por parque por semana, mes y anio
   ========================================================= */

exec reportes.sp_ingresos;
exec reportes.sp_ingresos_xml;

exec reportes.sp_ingresos_filt null, null, "MES", null;
exec reportes.sp_ingresos_filt null, null, "MES", 1;
exec reportes.sp_ingresos_filt "20260401", "20260801", "MES", 1;

exec reportes.sp_ingresos_xml_filt null, null, "MES", null;
exec reportes.sp_ingresos_xml_filt null, null, "MES", 1;
exec reportes.sp_ingresos_xml_filt "20260401", "20260801", "MES", 1;

/* =========================================================
   Matriz de visitas: tabla cruzada mostrando visitas por mes y parque
   ========================================================= */

exec reportes.sp_matriz_visitas 2026;
exec reportes.sp_matriz_visitas_xml 2026;
