#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git -c core.fileMode=false diff 27872b83b0932cc419116f79e442963cced935bb
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[all]
git checkout 27872b83b0932cc419116f79e442963cced935bb pvlib/tests/test_pvsystem.py pvlib/tests/test_tracking.py
git apply -v - <<'EOF_114329324912'
diff --git a/pvlib/tests/test_pvsystem.py b/pvlib/tests/test_pvsystem.py
--- a/pvlib/tests/test_pvsystem.py
+++ b/pvlib/tests/test_pvsystem.py
@@ -1119,23 +1119,43 @@ def test_PVSystem_localize_with_latlon():
 
 
 def test_PVSystem___repr__():
-    system = pvsystem.PVSystem(module='blah', inverter='blarg', name='pv ftw')
-
-    expected = ('PVSystem: \n  name: pv ftw\n  surface_tilt: 0\n  '
-                'surface_azimuth: 180\n  module: blah\n  inverter: blarg\n  '
-                'albedo: 0.25\n  racking_model: open_rack')
-
+    system = pvsystem.PVSystem(
+        module='blah', inverter='blarg', name='pv ftw',
+        temperature_model_parameters={'a': -3.56})
+
+    expected = """PVSystem:
+  name: pv ftw
+  surface_tilt: 0
+  surface_azimuth: 180
+  module: blah
+  inverter: blarg
+  albedo: 0.25
+  racking_model: open_rack
+  module_type: glass_polymer
+  temperature_model_parameters: {'a': -3.56}"""
     assert system.__repr__() == expected
 
 
 def test_PVSystem_localize___repr__():
-    system = pvsystem.PVSystem(module='blah', inverter='blarg', name='pv ftw')
+    system = pvsystem.PVSystem(
+        module='blah', inverter='blarg', name='pv ftw',
+        temperature_model_parameters={'a': -3.56})
     localized_system = system.localize(latitude=32, longitude=-111)
-
-    expected = ('LocalizedPVSystem: \n  name: None\n  latitude: 32\n  '
-                'longitude: -111\n  altitude: 0\n  tz: UTC\n  '
-                'surface_tilt: 0\n  surface_azimuth: 180\n  module: blah\n  '
-                'inverter: blarg\n  albedo: 0.25\n  racking_model: open_rack')
+    # apparently name is not preserved when creating a system using localize
+    expected = """LocalizedPVSystem:
+  name: None
+  latitude: 32
+  longitude: -111
+  altitude: 0
+  tz: UTC
+  surface_tilt: 0
+  surface_azimuth: 180
+  module: blah
+  inverter: blarg
+  albedo: 0.25
+  racking_model: open_rack
+  module_type: glass_polymer
+  temperature_model_parameters: {'a': -3.56}"""
 
     assert localized_system.__repr__() == expected
 
@@ -1158,16 +1178,24 @@ def test_LocalizedPVSystem_creation():
 
 
 def test_LocalizedPVSystem___repr__():
-    localized_system = pvsystem.LocalizedPVSystem(latitude=32,
-                                                  longitude=-111,
-                                                  module='blah',
-                                                  inverter='blarg',
-                                                  name='my name')
-
-    expected = ('LocalizedPVSystem: \n  name: my name\n  latitude: 32\n  '
-                'longitude: -111\n  altitude: 0\n  tz: UTC\n  '
-                'surface_tilt: 0\n  surface_azimuth: 180\n  module: blah\n  '
-                'inverter: blarg\n  albedo: 0.25\n  racking_model: open_rack')
+    localized_system = pvsystem.LocalizedPVSystem(
+        latitude=32, longitude=-111, module='blah', inverter='blarg',
+        name='my name', temperature_model_parameters={'a': -3.56})
+
+    expected = """LocalizedPVSystem:
+  name: my name
+  latitude: 32
+  longitude: -111
+  altitude: 0
+  tz: UTC
+  surface_tilt: 0
+  surface_azimuth: 180
+  module: blah
+  inverter: blarg
+  albedo: 0.25
+  racking_model: open_rack
+  module_type: glass_polymer
+  temperature_model_parameters: {'a': -3.56}"""
 
     assert localized_system.__repr__() == expected
 
diff --git a/pvlib/tests/test_tracking.py b/pvlib/tests/test_tracking.py
--- a/pvlib/tests/test_tracking.py
+++ b/pvlib/tests/test_tracking.py
@@ -438,28 +438,51 @@ def test_get_irradiance():
 
 
 def test_SingleAxisTracker___repr__():
-    system = tracking.SingleAxisTracker(max_angle=45, gcr=.25,
-                                        module='blah', inverter='blarg')
-    expected = ('SingleAxisTracker: \n  axis_tilt: 0\n  axis_azimuth: 0\n  '
-                'max_angle: 45\n  backtrack: True\n  gcr: 0.25\n  '
-                'name: None\n  surface_tilt: None\n  surface_azimuth: None\n  '
-                'module: blah\n  inverter: blarg\n  albedo: 0.25\n  '
-                'racking_model: open_rack')
+    system = tracking.SingleAxisTracker(
+        max_angle=45, gcr=.25, module='blah', inverter='blarg',
+        temperature_model_parameters={'a': -3.56})
+    expected = """SingleAxisTracker:
+  axis_tilt: 0
+  axis_azimuth: 0
+  max_angle: 45
+  backtrack: True
+  gcr: 0.25
+  name: None
+  surface_tilt: None
+  surface_azimuth: None
+  module: blah
+  inverter: blarg
+  albedo: 0.25
+  racking_model: open_rack
+  module_type: glass_polymer
+  temperature_model_parameters: {'a': -3.56}"""
     assert system.__repr__() == expected
 
 
 def test_LocalizedSingleAxisTracker___repr__():
-    localized_system = tracking.LocalizedSingleAxisTracker(latitude=32,
-                                                           longitude=-111,
-                                                           module='blah',
-                                                           inverter='blarg',
-                                                           gcr=0.25)
-
-    expected = ('LocalizedSingleAxisTracker: \n  axis_tilt: 0\n  '
-                'axis_azimuth: 0\n  max_angle: 90\n  backtrack: True\n  '
-                'gcr: 0.25\n  name: None\n  surface_tilt: None\n  '
-                'surface_azimuth: None\n  module: blah\n  inverter: blarg\n  '
-                'albedo: 0.25\n  racking_model: open_rack\n  '
-                'latitude: 32\n  longitude: -111\n  altitude: 0\n  tz: UTC')
+    localized_system = tracking.LocalizedSingleAxisTracker(
+        latitude=32, longitude=-111, module='blah', inverter='blarg',
+        gcr=0.25, temperature_model_parameters={'a': -3.56})
+    # apparently the repr order is different for LocalizedSingleAxisTracker
+    # than for LocalizedPVSystem. maybe a MRO thing.
+    expected = """LocalizedSingleAxisTracker:
+  axis_tilt: 0
+  axis_azimuth: 0
+  max_angle: 90
+  backtrack: True
+  gcr: 0.25
+  name: None
+  surface_tilt: None
+  surface_azimuth: None
+  module: blah
+  inverter: blarg
+  albedo: 0.25
+  racking_model: open_rack
+  module_type: glass_polymer
+  temperature_model_parameters: {'a': -3.56}
+  latitude: 32
+  longitude: -111
+  altitude: 0
+  tz: UTC"""
 
     assert localized_system.__repr__() == expected

EOF_114329324912
: '>>>>> Start Test Output'
pytest -rA pvlib/tests/test_pvsystem.py pvlib/tests/test_tracking.py
: '>>>>> End Test Output'
git checkout 27872b83b0932cc419116f79e442963cced935bb pvlib/tests/test_pvsystem.py pvlib/tests/test_tracking.py
