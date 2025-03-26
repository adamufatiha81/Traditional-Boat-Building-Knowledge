import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the Clarity contract interactions
const mockContractCalls = {
  startApprenticeship: vi.fn(),
  getApprenticeship: vi.fn(),
  completeApprenticeship: vi.fn(),
  certifySkill: vi.fn(),
  getSkill: vi.fn(),
  updateSkillProficiency: vi.fn()
};

// Mock apprenticeship data
const mockApprenticeshipData = {
  master: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  apprentice: "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG",
  "boat-type": "Traditional Canoe",
  "start-time": 12345,
  "end-time": { type: "none" },
  status: "ACTIVE",
  description: "Learning traditional cedar strip canoe building techniques"
};

const mockSkillData = {
  "skill-name": "Steam bending ribs",
  proficiency: 75,
  "certified-time": 12346,
  notes: "Good progress on steam bending techniques"
};

describe('Apprenticeship Tracking Contract', () => {
  beforeEach(() => {
    vi.resetAllMocks();
    
    mockContractCalls.getApprenticeship.mockResolvedValue(mockApprenticeshipData);
    mockContractCalls.getSkill.mockResolvedValue(mockSkillData);
    mockContractCalls.startApprenticeship.mockResolvedValue({
      value: 1,
      type: "ok"
    });
    mockContractCalls.completeApprenticeship.mockResolvedValue({
      value: true,
      type: "ok"
    });
    mockContractCalls.certifySkill.mockResolvedValue({
      value: 1,
      type: "ok"
    });
    mockContractCalls.updateSkillProficiency.mockResolvedValue({
      value: true,
      type: "ok"
    });
  });
  
  describe('startApprenticeship', () => {
    it('should successfully start a new apprenticeship', async () => {
      const result = await mockContractCalls.startApprenticeship(
          "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG",
          "Traditional Canoe",
          "Learning traditional cedar strip canoe building techniques"
      );
      
      expect(mockContractCalls.startApprenticeship).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(1);
    });
  });
  
  describe('getApprenticeship', () => {
    it('should return apprenticeship data for a valid ID', async () => {
      const result = await mockContractCalls.getApprenticeship(1);
      
      expect(mockContractCalls.getApprenticeship).toHaveBeenCalledTimes(1);
      expect(result).toEqual(mockApprenticeshipData);
    });
  });
  
  describe('completeApprenticeship', () => {
    it('should successfully complete an apprenticeship', async () => {
      const result = await mockContractCalls.completeApprenticeship(1);
      
      expect(mockContractCalls.completeApprenticeship).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(true);
    });
  });
  
  describe('certifySkill', () => {
    it('should successfully certify a skill for an apprentice', async () => {
      const result = await mockContractCalls.certifySkill(
          1,
          "Steam bending ribs",
          75,
          "Good progress on steam bending techniques"
      );
      
      expect(mockContractCalls.certifySkill).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(1);
    });
  });
  
  describe('updateSkillProficiency', () => {
    it('should successfully update skill proficiency', async () => {
      const result = await mockContractCalls.updateSkillProficiency(
          1,
          1,
          85,
          "Significant improvement in steam bending techniques"
      );
      
      expect(mockContractCalls.updateSkillProficiency).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(true);
    });
  });
});
