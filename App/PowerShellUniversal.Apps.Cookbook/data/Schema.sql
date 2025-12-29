PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS Recipes (
    RecipeId       INTEGER PRIMARY KEY AUTOINCREMENT,
    Title          TEXT NOT NULL,
    Description    TEXT,
    Notes          TEXT,
    PrepTimeMin    INTEGER,
    CookTimeMin    INTEGER,
    Servings       INTEGER,
    Source         TEXT,

    -- ✅ Favorites + image support
    IsFavorite     INTEGER NOT NULL DEFAULT 0,
    ImageFileName  TEXT,
    ImageUpdatedAt TEXT,

    CreatedAt      TEXT NOT NULL DEFAULT (datetime('now')),
    UpdatedAt      TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS Ingredients (
    IngredientId INTEGER PRIMARY KEY AUTOINCREMENT,
    RecipeId     INTEGER NOT NULL,
    Item         TEXT NOT NULL,
    Quantity     TEXT,
    Unit         TEXT,
    SortOrder    INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (RecipeId) REFERENCES Recipes(RecipeId) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Steps (
    StepId       INTEGER PRIMARY KEY AUTOINCREMENT,
    RecipeId     INTEGER NOT NULL,
    Instruction  TEXT NOT NULL,
    SortOrder    INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (RecipeId) REFERENCES Recipes(RecipeId) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Tags (
    TagId        INTEGER PRIMARY KEY AUTOINCREMENT,
    Name         TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS RecipeTags (
    RecipeId     INTEGER NOT NULL,
    TagId        INTEGER NOT NULL,
    PRIMARY KEY (RecipeId, TagId),
    FOREIGN KEY (RecipeId) REFERENCES Recipes(RecipeId) ON DELETE CASCADE,
    FOREIGN KEY (TagId) REFERENCES Tags(TagId) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS IX_Recipes_Title ON Recipes(Title);
CREATE INDEX IF NOT EXISTS IX_Recipes_IsFavorite ON Recipes(IsFavorite);
CREATE INDEX IF NOT EXISTS IX_Ingredients_RecipeId ON Ingredients(RecipeId);
CREATE INDEX IF NOT EXISTS IX_Steps_RecipeId ON Steps(RecipeId);
CREATE INDEX IF NOT EXISTS IX_Tags_Name ON Tags(Name);
