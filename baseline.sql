-- CreateTable
CREATE TABLE "contacts" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "title" TEXT,
    "associatedAccount" TEXT,
    "emailAddress" TEXT,
    "deskPhone" TEXT,
    "mobilePhone" TEXT,
    "city" TEXT,
    "state" TEXT,
    "country" TEXT,
    "timeZone" TEXT,
    "source" TEXT,
    "owner" TEXT,
    "status" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "createdBy" TEXT NOT NULL,
    "updatedBy" TEXT NOT NULL,
    CONSTRAINT "contacts_associatedAccount_fkey" FOREIGN KEY ("associatedAccount") REFERENCES "accounts" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "accounts" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "accountName" TEXT NOT NULL,
    "accountRating" TEXT,
    "accountOwner" TEXT,
    "status" TEXT,
    "industry" TEXT,
    "revenue" TEXT,
    "numberOfEmployees" TEXT,
    "addressLine1" TEXT,
    "addressLine2" TEXT,
    "city" TEXT,
    "state" TEXT,
    "country" TEXT,
    "zipPostCode" TEXT,
    "timeZone" TEXT,
    "boardNumber" TEXT,
    "website" TEXT,
    "geo" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "createdBy" TEXT NOT NULL,
    "updatedBy" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "activity_logs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "activityType" TEXT NOT NULL,
    "associatedContact" TEXT,
    "associatedAccount" TEXT,
    "dateTime" DATETIME NOT NULL,
    "followUpSchedule" TEXT,
    "summary" TEXT,
    "outcomeDisposition" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "createdBy" TEXT NOT NULL,
    "updatedBy" TEXT NOT NULL,
    CONSTRAINT "activity_logs_associatedContact_fkey" FOREIGN KEY ("associatedContact") REFERENCES "contacts" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "activity_logs_associatedAccount_fkey" FOREIGN KEY ("associatedAccount") REFERENCES "accounts" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "active_deals" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "dealOwner" TEXT,
    "dealName" TEXT NOT NULL,
    "businessLine" TEXT,
    "associatedAccount" TEXT,
    "associatedContact" TEXT,
    "closingDate" DATETIME,
    "probability" TEXT,
    "dealValue" TEXT,
    "approvedBy" TEXT,
    "description" TEXT,
    "nextStep" TEXT,
    "geo" TEXT,
    "entity" TEXT,
    "stage" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "createdBy" TEXT NOT NULL,
    "updatedBy" TEXT NOT NULL,
    CONSTRAINT "active_deals_associatedAccount_fkey" FOREIGN KEY ("associatedAccount") REFERENCES "accounts" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "active_deals_associatedContact_fkey" FOREIGN KEY ("associatedContact") REFERENCES "contacts" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "leads" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "company" TEXT NOT NULL,
    "title" TEXT,
    "phone" TEXT,
    "email" TEXT,
    "leadSource" TEXT,
    "status" TEXT,
    "rating" TEXT,
    "owner" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "createdBy" TEXT NOT NULL,
    "updatedBy" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "user_profiles" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "title" TEXT,
    "department" TEXT,
    "role" TEXT DEFAULT 'User',
    "profilePhoto" TEXT,
    "timezone" TEXT,
    "language" TEXT DEFAULT 'en',
    "emailNotifications" BOOLEAN NOT NULL DEFAULT true,
    "smsNotifications" BOOLEAN NOT NULL DEFAULT false,
    "pushNotifications" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateIndex
CREATE UNIQUE INDEX "user_profiles_email_key" ON "user_profiles"("email");

