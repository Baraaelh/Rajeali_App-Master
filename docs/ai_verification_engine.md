# AI Verification Engine Blueprint

## Recommended AI APIs for Semantic Similarity
1. **OpenAI Embeddings (`text-embedding-3-large` or `text-embedding-3-small`)**
   - Best balance for Arabic + English semantic matching.
   - Workflow: generate vectors for reference answer and claimant answer, then compute cosine similarity.
2. **Hugging Face Inference API (`sentence-transformers/paraphrase-multilingual-mpnet-base-v2`)**
   - Good multilingual fallback when OpenAI is not available.
   - Use cosine similarity over embeddings server-side.

## Suggested Database Schema (server side)
```sql
CREATE TABLE users (
  user_id UUID PRIMARY KEY,
  encrypted_national_id TEXT NOT NULL,
  national_id_hash CHAR(64) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE posts (
  post_id UUID PRIMARY KEY,
  finder_user_id UUID NOT NULL REFERENCES users(user_id),
  image_url TEXT NOT NULL,
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  posted_at TIMESTAMP NOT NULL,
  description TEXT NOT NULL,
  verification_question TEXT NOT NULL,
  encrypted_reference_answer TEXT NOT NULL
);

CREATE TABLE verification_attempts (
  attempt_id UUID PRIMARY KEY,
  post_id UUID NOT NULL REFERENCES posts(post_id),
  claimant_user_id UUID NOT NULL REFERENCES users(user_id),
  claimant_answer TEXT NOT NULL,
  semantic_score DECIMAL(5,4) NOT NULL,
  is_success BOOLEAN NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE chat_rooms (
  room_id UUID PRIMARY KEY,
  post_id UUID NOT NULL REFERENCES posts(post_id),
  finder_user_id UUID NOT NULL REFERENCES users(user_id),
  claimant_user_id UUID NOT NULL REFERENCES users(user_id),
  opened_at TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE (post_id, claimant_user_id)
);

CREATE TABLE chat_messages (
  message_id UUID PRIMARY KEY,
  room_id UUID NOT NULL REFERENCES chat_rooms(room_id),
  sender_user_id UUID NOT NULL REFERENCES users(user_id),
  message_body TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## Verification Flow (from answer to chat socket)
1. Claimant submits answer for selected post.
2. Backend decrypts stored reference answer in secure runtime only.
3. AI service computes semantic similarity score.
4. Rule engine checks `score >= 0.70`.
5. If success:
   - Persist successful attempt log.
   - Create chat room if not exists.
   - Return `chat_access = granted` to app.
   - App opens socket channel for that room.
6. If fail:
   - Persist failed attempt log.
   - Increment `failed_count` for (`post_id`, `claimant_user_id`).
   - If failed count reaches 3, block further attempts for that post.
   - Return user-safe feedback message without exposing exact threshold.

## Security notes
- Keep encryption keys in server KMS (AWS KMS, GCP KMS, Azure Key Vault).
- Never expose reference answers or national IDs in admin UI.
- Keep audit logs immutable for dispute handling.

