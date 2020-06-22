#groupadd finance
#groupadd business_dev
#groupadd contractor
#groupadd csr
#groupadd etl
#groupadd intern

ipa group-add finance --desc="finance"
ipa group-add business_dev --desc="business_dev"
ipa group-add contractor --desc="contractor"
ipa group-add csr --desc="csr"
ipa group-add etl --desc="etl"
ipa group-add intern --desc="intern"

#useradd -g hadoop admin
#useradd -g finance john_finance
#useradd -g business_dev mark_bizdev
#useradd -g contractor jeremy_contractor
#useradd -g csr diane_csr
#useradd -g etl log_monitor
#useradd -g etl etl_user
#useradd -g intern scott_intern

ipa user-add john_finance  --password
ipa group-add-member finance --users=john_finance

ipa user-add mark_bizdev  --password
ipa group-add-member business_dev --users=mark_bizdev

ipa user-add jeremy_contractor  --password
ipa group-add-member contractor --users=jeremy_contractor

ipa user-add diane_csr  --password
ipa group-add-member csr --users=diane_csr

ipa user-add log_monitor  --password
ipa user-add etl_user  --password
ipa group-add-member etl --users=log_monitor,etl_user

ipa user-add scott_intern  --password
ipa group-add-member intern --users=scott_intern



#groupadd us_employee
#groupadd eu_employee
#groupadd analyst
#groupadd hr
#groupadd dpo

ipa group-add us_employee --desc="us_employee"
ipa group-add eu_employee --desc="eu_employee"
ipa group-add analyst --desc="analyst"
ipa group-add hr --desc="hr"
ipa group-add dpo --desc="dpo"

#useradd -g analyst joe_analyst
#useradd -g hr kate_hr
#useradd -g hr sasha_eu_hr
#useradd -g hr ivanna_eu_hr
#useradd -g dpo michelle_dpo

ipa user-add joe_analyst  --password
ipa group-add-member analyst --users=joe_analyst

ipa user-add kate_hr  --password
ipa user-add sasha_eu_hr  --password
ipa user-add ivanna_eu_hr  --password
ipa group-add-member hr --users=kate_hr,sasha_eu_hr,ivanna_eu_hr

ipa user-add michelle_dpo  --password
ipa group-add-member dpo --users=michelle_dpo




#below users should also be added to us_employee or eu_employee
#usermod -a -G us_employee joe_analyst
#usermod -a -G us_employee kate_hr
#usermod -a -G eu_employee sasha_eu_hr
#usermod -a -G eu_employee ivanna_eu_hr
#usermod -a -G eu_employee michelle_dpo

ipa group-add-member us_employee --users=joe_analyst,kate_hr
ipa group-add-member eu_employee --users=sasha_eu_hr,ivanna_eu_hr,michelle_dpo



#echo BadPass#1 > passwd.txt
#echo BadPass#1 >> passwd.txt
#
#passwd joe_analyst < passwd.txt
#passwd ivanna_eu_hr < passwd.txt
#passwd etl_user < passwd.txt
#passwd scott_intern < passwd.txt
#
#rm -f passwd.txt
