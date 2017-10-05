DELETE FROM category *;
DELETE FROM manufacturer *;
DELETE FROM accessories *;

INSERT INTO "public"."category"("id","name","image")
VALUES
(1,E'Phones',E'icons/smartphone.svg');
