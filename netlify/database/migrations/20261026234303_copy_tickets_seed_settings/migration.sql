-- Copia los números existentes al modelo por puesto / media fracción.
INSERT INTO "ticket_shares" ("raffle_id", "number", "slot", "kind", "status", "seller_id", "buyer", "phone", "created_at", "updated_at")
SELECT "raffle_id", "number", 1,
  CASE WHEN "status" = 'mitad' OR "halves" = 2 THEN 'mitad' ELSE 'completo' END,
  CASE WHEN "status" = 'reservado' THEN 'reservado' ELSE 'vendido' END,
  "seller_id", split_part("buyer", ' / ', 1), "phone", "updated_at", "updated_at"
FROM "tickets"
ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO "ticket_shares" ("raffle_id", "number", "slot", "kind", "status", "seller_id", "buyer", "phone", "created_at", "updated_at")
SELECT "raffle_id", "number", 2, 'mitad', 'vendido', "seller_id",
  coalesce(nullif(split_part("buyer", ' / ', 2), ''), "buyer"), "phone", "updated_at", "updated_at"
FROM "tickets"
WHERE "halves" = 2
ON CONFLICT DO NOTHING;
--> statement-breakpoint
INSERT INTO "settings" ("key", "value") VALUES ('business', '{"whatsapp":"573001234567","confirmTo":"numero","groupUrl":"","channelUrl":"","instagram":"@dinamicas365","paymentMethods":[{"name":"Nequi","holder":"Dinamicas365","account":"300 123 4567"},{"name":"Daviplata","holder":"Dinamicas365","account":"300 123 4567"},{"name":"Bancolombia Ahorros","holder":"Dinamicas365 SAS","account":"123-456789-01"}]}'::jsonb)
ON CONFLICT ("key") DO NOTHING;
--> statement-breakpoint
INSERT INTO "rule_templates" ("text") VALUES
  ('Últimas 2 cifras'), ('Últimas 3 cifras'), ('Primeras 2 cifras'), ('Primeras 3 cifras'),
  ('Cifras invertidas'), ('Premio anticipado')
ON CONFLICT DO NOTHING;
