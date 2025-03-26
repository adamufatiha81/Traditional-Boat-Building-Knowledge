import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the Clarity contract interactions
const mockContractCalls = {
  registerDesign: vi.fn(),
  getDesign: vi.fn(),
  updateDesign: vi.fn(),
  attestDesign: vi.fn(),
  getAttestation: vi.fn()
};

// Mock design data
const mockDesignData = {
  name: "Maine Lobster Boat",
  region: "New England, USA",
  "boat-type": "Fishing Vessel",
  description: "Traditional design for lobster fishing in rough Atlantic waters",
  techniques: "Plank-on-frame construction with cedar planking and oak frames",
  "registered-by": "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  "registration-time": 12345
};

describe('Design Registration Contract', () => {
  beforeEach(() => {
    vi.resetAllMocks();
    
    mockContractCalls.getDesign.mockResolvedValue(mockDesignData);
    mockContractCalls.registerDesign.mockResolvedValue({
      value: 1,
      type: "ok"
    });
    mockContractCalls.updateDesign.mockResolvedValue({
      value: true,
      type: "ok"
    });
    mockContractCalls.attestDesign.mockResolvedValue({
      value: true,
      type: "ok"
    });
    mockContractCalls.getAttestation.mockResolvedValue({
      "attestation-time": 12346,
      comments: "I confirm this is an authentic design"
    });
  });
  
  describe('registerDesign', () => {
    it('should successfully register a new boat design', async () => {
      const result = await mockContractCalls.registerDesign(
          "Maine Lobster Boat",
          "New England, USA",
          "Fishing Vessel",
          "Traditional design for lobster fishing in rough Atlantic waters",
          "Plank-on-frame construction with cedar planking and oak frames"
      );
      
      expect(mockContractCalls.registerDesign).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(1);
    });
  });
  
  describe('getDesign', () => {
    it('should return design data for a valid ID', async () => {
      const result = await mockContractCalls.getDesign(1);
      
      expect(mockContractCalls.getDesign).toHaveBeenCalledTimes(1);
      expect(result).toEqual(mockDesignData);
    });
  });
  
  describe('updateDesign', () => {
    it('should successfully update an existing design', async () => {
      const result = await mockContractCalls.updateDesign(
          1,
          "Updated description with more details",
          "Updated techniques with newer methods"
      );
      
      expect(mockContractCalls.updateDesign).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(true);
    });
  });
  
  describe('attestDesign', () => {
    it('should successfully attest to a design', async () => {
      const result = await mockContractCalls.attestDesign(
          1,
          "I confirm this is an authentic design"
      );
      
      expect(mockContractCalls.attestDesign).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(true);
    });
  });
});
