create or replace procedure pr_scim 
    (
    p_user_id in varchar2,
    p_email in varchar2,
    p_first_name in varchar2, 
    p_last_name in varchar2,
    p_role_list in varchar2,
    p_branch_list in varchar2,
    p_home_branch in varchar2,
    p_user_name in varchar2,
    p_mobile in varchar2,
    p_env in varchar2,
    p_result out varchar2
    )
is
    l_req json_object_t := new json_object_t();
    L_NAME               JSON_OBJECT_T := NEW JSON_OBJECT_T;
    L_EMAIL              JSON_OBJECT_T := NEW JSON_OBJECT_T;
    L_PHONE              JSON_OBJECT_T := NEW JSON_OBJECT_T;
    L_ENTERPRISE         JSON_OBJECT_T := NEW JSON_OBJECT_T;
    L_META               JSON_OBJECT_T := NEW JSON_OBJECT_T;
    L_CUSTOM             JSON_OBJECT_T := NEW JSON_OBJECT_T;
    L_MEMBERS            JSON_OBJECT_T := NEW JSON_OBJECT_T;
    l_url varchar2(4000);
    r tb_scim_requests%rowtype;
begin
    dbms_output.put_line('inside scim client proc');
    if p_env is null then p_result := 'Env cannot be blank'; return; end if;
    if p_home_branch is null then p_result := 'Home Branch cannot be blank'; return; end if;

    L_NAME.PUT('familyName', p_last_name);
    L_NAME.PUT('givenName', p_first_name);
    L_NAME.PUT('formatted', p_first_name
                            || ' '
                            || p_last_name);

    L_EMAIL.PUT('value', p_email);
    L_EMAIL.PUT('type', 'work');
    L_EMAIL.PUT('primary', 'true');
    L_PHONE.PUT('value', p_mobile);
    L_ENTERPRISE.PUT('title', 'junior assistant');
    L_ENTERPRISE.PUT('company', 'KBZ');
    L_META.PUT('resourceType', 'S');
    L_CUSTOM.PUT('Home_Branch', p_home_branch);
    L_CUSTOM.PUT('NRC', '12/xxxx(N)000001');
    L_CUSTOM.PUT('VC_FC', 'S');
    L_CUSTOM.PUT('User_Status', 'E');
    L_CUSTOM.PUT('Record_Stat', 'O');
    L_MEMBERS.PUT('role', p_role_list);

    L_MEMBERS.PUT('branch', p_branch_list);

    L_CUSTOM.PUT('members', L_MEMBERS);

    l_req.put('schemas', '[
			"urn:ietf:params:scim:schemas:core:1.0:User",
			"urn:scim:schemas:extension:enterprise:1.0",
			"urn:scim:my:custom:schema"]');
    l_req.put('userId',p_user_id);
    l_req.put('username',p_user_name);
    l_req.put('userName',p_user_name);
    l_req.PUT('name', L_NAME);
    l_req.PUT('emails', L_EMAIL);
    l_req.PUT('phoneNumbers', L_PHONE);
    l_req.PUT('active', true);
    l_req.PUT('urn:scim:schemas:extension:enterprise:1.0', L_ENTERPRISE);
    l_req.PUT('meta', L_META);
    l_req.PUT('urn:scim:my:custom:schema', L_CUSTOM);

    r.user_id := v('APP_USER');
    r.req_ts := systimestamp;
    r.req := l_req.to_string();
    select scim_url_user_create into l_url from tb_saml_envs where env_name = p_env;

    apex_web_service.g_request_headers(1).name := 'Content-Type';  
    apex_web_service.g_request_headers(1).value := 'application/json';
    r.res := apex_web_service.make_rest_request
        (p_url => l_url,
        p_http_method  => 'POST',
        p_body => r.req,
        p_transfer_timeout => 3600
        );
    r.res_ts := systimestamp;
    p_result := r.res;
    insert into tb_scim_requests values r;
exception
    when others
    then 
        p_result := sqlerrm;
end;
