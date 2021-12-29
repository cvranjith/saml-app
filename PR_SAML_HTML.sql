create or replace procedure pr_saml_html(p_saml_token in varchar2) is 
xx varchar2(32767);
yy  varchar2(32767);
dd   varchar2(32767);
saml_user varchar2(32767);
n number := 0;
num_cards_in_a_row number := 5;
t dbms_sql.varchar2_table;
type ty_envs is table of tb_saml_envs%rowtype index by binary_integer;
tb_envs ty_envs;

type ty_apps is table of tb_saml_env_apps%rowtype index by binary_integer;
tb_apps ty_apps;

function fn_envs return ty_envs result_cache
is
t ty_envs;
begin
  for i in (select * from tb_saml_envs order by ord)
  loop
     t(t.count+1) := i;
  end loop;
  return t;
end;

function fn_apps(p_env_name in varchar2) return ty_apps result_cache
is
t ty_apps;
begin
  for i in (select * from tb_saml_env_apps where env_name = p_env_name order by ord)
  loop
     t(t.count+1) := i;
  end loop;
  return t;
end;

function fn_app_img (p_app_name in varchar2) return varchar2 result_cache
is
 a varchar2(1000);
begin
  select img_tag into a from tb_saml_apps where app_name = p_app_name;
  return a;
exception
  when no_data_found
  then
    return '<span aria-hidden="true" class="fa fa-cube fa-5x"></span>';
end;

begin
begin
--select xmltype(utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw (p_saml_token))))
--into xx
--from dual;
xx := (utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw (p_saml_token))));
dd := '<table>';
for i in 1..4
loop
    select 
    --yy := yy||chr(10)
        xmltype(xx).extract('/samlp:Response/saml:Assertion/saml:AttributeStatement/saml:Attribute['||i||']/saml:AttributeValue/text()','xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" xmlns:enc="http://www.w3.org/2001/04/xmlenc#" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:x500="urn:oasis:names:tc:SAML:2.0:profiles:attribute:X500" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"').getstringval()
     into yy
    from dual;
    dd := dd||'<tr><td>Attribute['||i||']</td><td><h1>'||yy||'</h1></td></tr>';
    t(i) := yy;
    saml_user := saml_user||upper(yy);
end loop;


exception
when others
then null;
end;
dd := dd||'<tr><td>LDAP User</td><td><h2>'||saml_user||'</h2></td></tr></table>';
--dd := dd||'<br><br><pre>'||xx||'</pre>';
dd := dd||'<textarea rows="10" cols="50">'||xx||'</textarea>';
dd := dd||'<textarea rows="10" cols="50">'||p_saml_token||'</textarea>';
--dd := dd||yy;
--insert into tmp_saml1 values (xx);

tb_envs := fn_envs;
htp.p('<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://static.oracle.com/cdn/apex/20.1.0.00.13-a/libraries/font-apex/2.1/css/font-apex.min.css?v=20.1.0.00.13" type="text/css" />
<style>
* {box-sizing: border-box}
body {font-family: "Lato", sans-serif;}
.tabcontent {
  float: left;
  padding: 0px 12px;
  border: none;
  width: 80%;
  border-left: none;
  height: 80%;
  display: none;
  margin-top: 50px;
}
.card {
  box-shadow: 0 4px 8px 0 rgba(0,0,0,0.2);
  transition: 0.3s;
  width: 200px;
  height: 200px;
  border-radius: 5px;
  text-align: center;
}

.card:hover {
  box-shadow: 0 8px 16px 0 rgba(0,0,0,0.2);
}

img {
  border-radius: 5px 5px 0 0;
}

.container {
  padding: 2px 16px;
}
.sidebar {
  height: 100%;
  width: 200px;
  position: fixed;
  z-index: 1;
  top: 0;
  left: 0;
  background-color: #111;
  overflow-x: hidden;
  padding-top: 16px;
}

.sidebar a {
  padding: 6px 8px 6px 16px;
  text-decoration: none;
  font-size: 20px;
  color: #818181;
  display: block;
}

.sidebar a:hover {
  color: #f1f1f1;
}

.main {
  margin-left: 200px;
}

a:link  {
    text-decoration: none;
    color: black;
}
a.link1:link {text-decoration: none; color:gray;}
a.link1:hover {background:white;}
      
#navbar {
  overflow: hidden;
  background-color: #f1f1f1;
  padding: 10px 10px;
  transition: 0.4s;
  position: fixed;
  width: 85%;
  top: 0;
  z-index: 99;
  margin-left: 200px;
}

#navbar a {
  float: left;
  color: black;
  text-align: center;
  padding: 12px;
  text-decoration: none;
  font-size: 18px; 
  line-height: 25px;
  border-radius: 4px;
}

#navbar a:hover {
  background-color: #ddd;
  color: black;
}

#navbar-right {
  float: right;
}

.card1 {
  box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2);
  max-width: 500px;
  margin: auto;
  text-align: center;
  font-family: arial;
}

.title1 {
  color: grey;
  font-size: 18px;
}
      
.label {
  color: white;
  padding: 8px;
}

.success {background-color: #4CAF50;} /* Green */
.info {background-color: #2196F3;} /* Blue */
.warning {background-color: #ff9800;} /* Orange */
.danger {background-color: #f44336;} /* Red */
.blacky {background-color: black;}
.grayy {background-color: #D2CFCE; font-size: 20px;}
      
</style>
</head>');
htp.p('<body onload="showEnv(event, '''||tb_envs(1).env_name||''');">');
htp.p('<input type="hidden" id="samltoken" name="samltoken" value="'||p_saml_token||'">');

htp.p('<div id="navbar">
  <div id="navbar-right">
    <a href="https://login-stage.oracle.com/oamfed/idp/initiatesso?providerid=fsgbu-japac-ri"><i class="fa fa-refresh fa-2x"></i> &nbsp Renew SAML </a>
    <a href="javascript:showEnv(event, ''Token Info'');"><i class="fa fa-info-square-o fa-2x"></i> &nbsp Token Info</a>
    <a href="https://apex.oraclecorp.com/pls/apex/fsgbu_japac_ri/r/saml-app/envs" target="_blank"><i class="fa fa-gears fa-2x"></i> &nbsp Admin </a>
    <a href="https://apex.oraclecorp.com/pls/apex/fsgbu_japac_ri/r/saml-app/scim?user_id='||t(1)||'&email='||t(2)||'&first_name='||t(3)||'&last_name='||t(4)||'" target="_blank"><i class="fa fa-user-circle fa-2x"></i> &nbsp SCIM </a>
    <a href="https://confluence.oraclecorp.com/confluence/display/FSGBUCT/Testing+FLEXCUBE+User+authentication+using+Oracle+SAML" target="_blank">About</a>
  </div>
</div>');

htp.p('<div class="sidebar">');

--htp.p('<a href="https://login-stage.oracle.com/oamfed/idp/initiatesso?providerid=fsgbu-japac-ri"><i class="fa fa-refresh fa-2x"></i> &nbsp Renew SAML </a>');

htp.p('<a href="#"> Environments </a>');

for i in tb_envs.first..tb_envs.last
loop
      htp.p('<a class="link1" href="javascript:showEnv(event, '''||tb_envs(i).env_name||''');"><i class="fa '||tb_envs(i).icon_class||' fa-2x"></i> &nbsp '||tb_envs(i).env_name||'</a>');
end loop;
htp.p('</div>');
htp.p('<div class="main">');

     
for i in tb_envs.first..tb_envs.last
loop
    htp.p('<div id="'||tb_envs(i).env_name||'" class="tabcontent">
      <h3>'||tb_envs(i).env_name||'</h3>
      <p>'||tb_envs(i).env_descr||'</p><table><tr>');
       tb_apps := fn_apps(tb_envs(i).env_name); 
       if tb_apps.count > 0
       then
         n := 0;
         for j in tb_apps.first..tb_apps.last
         loop
            if n = num_cards_in_a_row then htp.p('</tr><tr>'); n := 0; end if;
            n := n+1;
            htp.p('<td><a href="javascript:post_to_url('''||tb_apps(j).app_url||''');">
<div class="card">'||
                  fn_app_img(tb_apps(j).app_name)
                  ||
  '<div class="container">
                  <p><span class="label blacky">
    '|| tb_apps(j).app_name ||'</span>
    <p><span class="label grayy">'||tb_apps(j).app_descr||'</span></p>
  </div>
</div>
</td>');

/*
if tb_apps(j).AUTO_SAML_API is not null
then
begin
yy := APEX_WEB_SERVICE.make_rest_request(
    p_url         => tb_apps(j).AUTO_SAML_API ,
    p_http_method => 'POST',
    p_body => '{"msgId": "'||sys_guid()||'","msgCode": "setSAMLDemoUser","samlID": "'||saml_user||'"}'
  );
  dd := dd||'<br>Auto Saml request sent for '||tb_envs(i).env_name||'/'||tb_apps(j).app_name||' Response : '||yy;
exception
when others
then
null;
end;
end if;
*/

         end loop;
       end if;
     htp.p('</tr></table></div>');

end loop;
htp.p('<div id="Token Info" class="tabcontent">'||dd||'</div>');
htp.p('</div>');

htp.p('
<script>
function showEnv(evt, envName) {
  var i, tabcontent, tablinks;
  tabcontent = document.getElementsByClassName("tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }
  document.getElementById(envName).style.display = "block";
}
function post_to_url(path) {
    var form = document.createElement("form");
    form.setAttribute("method", "post");
    form.setAttribute("action", path);
    form.setAttribute("target", "_blank");
    var hiddenField = document.createElement("input");
    hiddenField.setAttribute("type", "hidden");
    hiddenField.setAttribute("name", "SAMLResponse");
    hiddenField.setAttribute("value", document.getElementById("samltoken").value );
    form.appendChild(hiddenField);
    document.body.appendChild(form);
    form.submit();
    document.body.removeChild(form);
}
</script>
</body></html>');
end;
