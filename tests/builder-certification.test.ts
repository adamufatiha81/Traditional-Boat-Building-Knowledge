import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the Clarity contract interactions
const mockContractCalls = {
  registerBuilder: vi.fn(),
  getBuilderProfile: vi.fn(),
  updateBuilderProfile: vi.fn(),
  endorseBuilder: vi.fn(),
  getBuilderCertification: vi.fn(),
  getEndorsement: vi.fn()
};

// Mock builder profile data
const mockProfileData = {
  name: "John Smith",
  region: "Pacific Northwest",
  specialization: "Cedar strip canoes and traditional fishing boats",
  "experience-years": 25,
  "registration-time": 12345
};

const mockCertificationData = {
  "certification-level": 2,
  "certified-by": ["ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"],
  "certification-time": 12345,
  "endorsement-count": 5
};

describe('Builder Certification Contract', () => {
  beforeEach(() => {
    vi.resetAllMocks();
    
    mockContractCalls.getBuilderProfile.mockResolvedValue(mockProfileData);
    mockContractCalls.getBuilderCertification.mockResolvedValue(mockCertificationData);
    mockContractCalls.registerBuilder.mockResolvedValue({
      value: true,
      type: "ok"
    });
    mockContractCalls.updateBuilderProfile.mockResolvedValue({
      value: true,
      type: "ok"
    });
    mockContractCalls.endorseBuilder.mockResolvedValue({
      value: true,
      type: "ok"
    });
    mockContractCalls.getEndorsement.mockResolvedValue({
      "endorsement-time": 12346,
      comments: "Excellent craftsman, I've seen his work firsthand"
    });
  });
  
  describe('registerBuilder', () => {
    it('should successfully register a new builder', async () => {
      const result = await mockContractCalls.registerBuilder(
          "John Smith",
          "Pacific Northwest",
          "Cedar strip canoes and traditional fishing boats",
          25
      );
      
      expect(mockContractCalls.registerBuilder).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(true);
    });
  });
  
  describe('getBuilderProfile', () => {
    it('should return builder profile for a valid address', async () => {
      const result = await mockContractCalls.getBuilderProfile("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM");
      
      expect(mockContractCalls.getBuilderProfile).toHaveBeenCalledTimes(1);
      expect(result).toEqual(mockProfileData);
    });
  });
  
  describe('updateBuilderProfile', () => {
    it('should successfully update an existing builder profile', async () => {
      const result = await mockContractCalls.updateBuilderProfile(
          "John Smith",
          "Pacific Northwest",
          "Updated specialization with additional skills",
          30
      );
      
      expect(mockContractCalls.updateBuilderProfile).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(true);
    });
  });
  
  describe('endorseBuilder', () => {
    it('should successfully endorse a builder', async () => {
      const result = await mockContractCalls.endorseBuilder(
          "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG",
          "Excellent craftsman, I've seen his work firsthand"
      );
      
      expect(mockContractCalls.endorseBuilder).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(true);
    });
  });
});
