CREATE TABLE "movements" (
	"id" serial PRIMARY KEY,
	"raffle_id" text NOT NULL,
	"number" text NOT NULL,
	"action" text NOT NULL,
	"seller_id" text NOT NULL,
	"buyer" text DEFAULT '' NOT NULL,
	"amount" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "orders" (
	"id" serial PRIMARY KEY,
	"raffle_id" text NOT NULL,
	"items" jsonb NOT NULL,
	"buyer" text NOT NULL,
	"phone" text NOT NULL,
	"city" text DEFAULT '' NOT NULL,
	"total" integer NOT NULL,
	"status" text DEFAULT 'pendiente' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "raffles" (
	"id" text PRIMARY KEY,
	"title" text NOT NULL,
	"tagline" text DEFAULT '' NOT NULL,
	"image" text NOT NULL,
	"status" text DEFAULT 'activa' NOT NULL,
	"total_numbers" integer NOT NULL,
	"price" integer NOT NULL,
	"half_price" integer NOT NULL,
	"lottery" text NOT NULL,
	"draw_date" timestamp with time zone NOT NULL,
	"prizes" jsonb DEFAULT '[]' NOT NULL,
	"rules" jsonb DEFAULT '[]' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sellers" (
	"id" text PRIMARY KEY,
	"name" text NOT NULL,
	"code" text NOT NULL UNIQUE,
	"commission_pct" integer DEFAULT 10 NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "tickets" (
	"raffle_id" text,
	"number" text,
	"status" text NOT NULL,
	"halves" integer,
	"seller_id" text NOT NULL,
	"buyer" text DEFAULT '' NOT NULL,
	"phone" text,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "tickets_pkey" PRIMARY KEY("raffle_id","number")
);
--> statement-breakpoint
CREATE INDEX "movements_seller_idx" ON "movements" ("seller_id");--> statement-breakpoint
CREATE INDEX "movements_created_idx" ON "movements" ("created_at");--> statement-breakpoint
ALTER TABLE "movements" ADD CONSTRAINT "movements_raffle_id_raffles_id_fkey" FOREIGN KEY ("raffle_id") REFERENCES "raffles"("id") ON DELETE CASCADE;--> statement-breakpoint
ALTER TABLE "orders" ADD CONSTRAINT "orders_raffle_id_raffles_id_fkey" FOREIGN KEY ("raffle_id") REFERENCES "raffles"("id") ON DELETE CASCADE;--> statement-breakpoint
ALTER TABLE "tickets" ADD CONSTRAINT "tickets_raffle_id_raffles_id_fkey" FOREIGN KEY ("raffle_id") REFERENCES "raffles"("id") ON DELETE CASCADE;