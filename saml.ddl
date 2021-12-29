CREATE TABLE  "TB_SAML_ENVS"
   (	"ENV_NAME" VARCHAR2(100),
	"ENV_DESCR" VARCHAR2(200),
	"ICON_CLASS" VARCHAR2(100),
	"ORD" NUMBER,
	"SCIM_URL_USER_CREATE" VARCHAR2(2000)
   )
/


CREATE TABLE  "TB_SAML_ADMIN_USERS"
   (	"USER_ID" VARCHAR2(2000)
   )
/


CREATE TABLE  "TB_SAML_APPS"
   (	"APP_NAME" VARCHAR2(100),
	"IMG_TAG" VARCHAR2(200)
   )
/


CREATE TABLE  "TB_SAML_ENVS"
   (	"ENV_NAME" VARCHAR2(100),
	"ENV_DESCR" VARCHAR2(200),
	"ICON_CLASS" VARCHAR2(100),
	"ORD" NUMBER,
	"SCIM_URL_USER_CREATE" VARCHAR2(2000)
   )
/


CREATE TABLE  "TB_SAML_ENV_APPS"
   (	"ENV_NAME" VARCHAR2(100),
	"APP_NAME" VARCHAR2(100),
	"APP_DESCR" VARCHAR2(100),
	"APP_URL" VARCHAR2(200),
	"ORD" NUMBER
   )
/


CREATE TABLE  "TB_SCIM_REQUESTS"
   (	"USER_ID" VARCHAR2(200),
	"REQ_TS" TIMESTAMP (6),
	"REQ" VARCHAR2(4000),
	"RES_TS" TIMESTAMP (6),
	"RES" VARCHAR2(4000)
   )
/
