CREATE TABLE "lookup_attempts" (
	"id" serial PRIMARY KEY,
	"ip" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "rule_templates" (
	"id" serial PRIMARY KEY,
	"text" text NOT NULL UNIQUE
);
--> statement-breakpoint
CREATE TABLE "settings" (
	"key" text PRIMARY KEY,
	"value" jsonb NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "ticket_shares" (
	"id" serial PRIMARY KEY,
	"raffle_id" text NOT NULL,
	"number" text NOT NULL,
	"slot" integer NOT NULL,
	"kind" text NOT NULL,
	"status" text NOT NULL,
	"seller_id" text NOT NULL,
	"order_id" integer,
	"buyer" text DEFAULT '' NOT NULL,
	"phone" text,
	"city" text DEFAULT '' NOT NULL,
	"note" text,
	"paid_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "orders" ADD COLUMN "seller_id" text;--> statement-breakpoint
ALTER TABLE "raffles" ADD COLUMN "results_published_at" timestamp with time zone;--> statement-breakpoint
CREATE INDEX "lookup_attempts_ip_idx" ON "lookup_attempts" ("ip","created_at");--> statement-breakpoint
CREATE UNIQUE INDEX "ticket_shares_slot_idx" ON "ticket_shares" ("raffle_id","number","slot");--> statement-breakpoint
CREATE INDEX "ticket_shares_phone_idx" ON "ticket_shares" ("phone");--> statement-breakpoint
CREATE INDEX "ticket_shares_seller_idx" ON "ticket_shares" ("seller_id");--> statement-breakpoint
CREATE INDEX "ticket_shares_order_idx" ON "ticket_shares" ("order_id");--> statement-breakpoint
ALTER TABLE "ticket_shares" ADD CONSTRAINT "ticket_shares_raffle_id_raffles_id_fkey" FOREIGN KEY ("raffle_id") REFERENCES "raffles"("id") ON DELETE CASCADE;--> statement-breakpoint
ALTER TABLE "ticket_shares" ADD CONSTRAINT "ticket_shares_order_id_orders_id_fkey" FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE SET NULL;