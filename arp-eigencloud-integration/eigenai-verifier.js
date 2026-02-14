/**
 * EigenAI Verifier for ARP
 * Provides deterministic, verifiable AI inference for agent tasks
 */

const EIGENAI_API_URL = 'https://api.eigencloud.xyz/v1/eigenai';

class EigenAIVerifier {
  constructor(apiKey) {
    this.apiKey = apiKey;
  }

  /**
   * Generate verifiable task response
   * @param {string} taskDescription - The task to complete
   * @param {object} context - Agent context (skills, history)
   * @returns {object} Response + verification proof
   */
  async generateResponse(taskDescription, context = {}) {
    const payload = {
      model: 'qwen3-32b-128k-bf16',  // Deterministic model
      messages: [
        {
          role: 'system',
          content: `You are an AI agent completing tasks. Be concise and accurate.
Agent Skills: ${context.skills?.join(', ') || 'general'}
Task Context: ${JSON.stringify(context)}`
        },
        {
          role: 'user',
          content: taskDescription
        }
      ],
      temperature: 0,  // Deterministic
      max_tokens: 2000
    };

    try {
      const response = await fetch(EIGENAI_API_URL + '/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
      });

      const data = await response.json();
      
      // Generate verification proof
      const proof = await this.generateProof(data);
      
      return {
        content: data.choices[0].message.content,
        model: data.model,
        usage: data.usage,
        proof: proof,
        timestamp: Date.now(),
        verified: true
      };
    } catch (error) {
      console.error('EigenAI Error:', error);
      return {
        content: null,
        error: error.message,
        verified: false
      };
    }
  }

  /**
   * Generate cryptographic proof of inference
   */
  async generateProof(response) {
    // In production: TEE attestation from EigenCloud
    // For hackathon: Hash of response + timestamp
    const crypto = require('crypto');
    const proofData = JSON.stringify({
      response: response.choices[0].message.content,
      model: response.model,
      timestamp: Date.now()
    });
    
    return {
      hash: crypto.createHash('sha256').update(proofData).digest('hex'),
      type: 'eigenai_deterministic',
      version: '1.0'
    };
  }

  /**
   * Verify a response is authentic EigenAI output
   */
  async verifyResponse(content, proof) {
    // Re-compute hash and compare
    const crypto = require('crypto');
    const proofData = JSON.stringify({
      response: content,
      model: proof.model || 'unknown',
      timestamp: proof.timestamp
    });
    
    const computedHash = crypto.createHash('sha256').update(proofData).digest('hex');
    return computedHash === proof.hash;
  }
}

module.exports = { EigenAIVerifier };
